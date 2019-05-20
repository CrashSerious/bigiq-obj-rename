#!/bin/bash

filePath="/var/tmp/objRename/"
logFile="objRename.log"
srcConfig="/config/bigip.conf"
tag=$1


# logging function
function log_entry {
  tStamp=$(date +%F\ %H:%M:%S.%3N)
  echo "$tStamp $returnStr" >> $filePath$logFile
}


##########################
# prep work
##########################

mkdir $filePath/ssl 2>/dev/null
mkdir $filePath/mon 2>/dev/null
mkdir $filePath/rul 2>/dev/null

# verify tag argument
if [ $# -eq 0 ] ; then
	echo -e "ERROR: No tag string specified\nUsage:\n$0 [tag]\n\tTag = string to be prepended to an existing user-defined BIG-IP object (monitor, iRule, and SSL-profile(certs and keys))\n"
	exit 1
fi

# verify HA is synched
syncStat=$(tmsh show cm sync-status | awk '/^Status/ {gsub (/Status +/,"",$0); print}')

if [ "$syncStat" != "In Sync" ] && [ "$syncStat" != "Standalone" ] ; then
  returnStr="Verify Sync Status: device HA is not in sync. Status is $syncStat. Exiting"
  echo $returnStr
  log_entry
  exit
fi

# save sys config
returnStr="Save Sys Config: Saving the running config to file before we start"
echo $returnStr
log_entry

tmsh save sys config

# make a backup of the current configuration for backout purposes
returnStr="Backup Config: backup current config for backout purposes"
echo $returnStr
log_entry

# scf
tmsh save sys config file pre-change_$(uname -n)_$(date +%F) no-passphrase
# ucs
tmsh save sys ucs pre-change_$(uname -n)_$(date +%F)

# take pre-change stats
returnStr="Obtaining pre-change pool member stats"
echo $returnStr
log_entry
tmsh show ltm pool field-fmt members | awk --posix  '/node-name/ {mem=$2} /addr/ {mbrAddr=$2} / port / {mbrPort=$2} /^ {12}status.availability-state/ {avStat=$2} /^ {12}status.enabled-state/ {enstate=$2} /^ {12}pool-name/ {pname=$2} /^ {8}}/ {print pname,mem,mbrAddr,mbrPort,avStat,enstate}' | sort -k 3,4 -k 1,1 > $filePath/prechange-stats

##########################
# monitors
##########################

# get monitors from config file and skip any monitors with tags and skip iapp created monitors
# write monitors that we will rename to a file
awk '/^ltm monitor/ && !/\/Common\/'$tag'-/ && !/\/Common\/.*\.app\//,/^}/' $srcConfig > $filePath/mon/orig-monitors

if [ "$(cat $filePath/mon/orig-monitors | wc -l)" -gt 0 ] ; then
  # create new file for monitor names which will be updated
  echo "Creating config file for new montiors: $filePath/mon/new-monitors"
  cp $filePath/mon/orig-monitors $filePath/mon/new-monitors


  for mon in $(awk '/^ltm monitor/ {gsub (/\/Common\//,"",$4);print $4}' $filePath/mon/orig-monitors); do
    #echo "$mon renaming to $mon-$tag"
    returnStr="Writing new monitor config: $mon renaming to $mon-$tag"
    #echo $returnStr
    log_entry

    sed -i 's/\/Common\/'$mon' {/\/Common\/'$tag'-'$mon' {/;s/defaults-from \/Common\/'$mon'$/defaults-from \/Common\/'$tag'-'$mon'/' $filePath/mon/new-monitors
  done 

  # load new monitors
  returnStr="Loading new monitor config"
  echo $returnStr
  log_entry

  tmsh load sys config file $filePath/mon/new-monitors merge

  # update pools and nodes with new monitors

  # nodes
  echo "# point nodes at new monitors" > $filePath/mon/new-tmshcommands
  awk '/^ltm monitor/ {gsub (/\/Common\//,"",$4);print $3,$4}' $filePath/mon/orig-monitors | while read type mon; do
    echo -ne "\r# checking for nodes that use monitor $type $mon                              "
    tmsh list ltm node monitor | awk '/^ltm node/ {gsub (/\/Common\//,"",$3); node=$3} /^    monitor '$mon'( |$)/ {print "tmsh modify ltm node",node,"monitor '$tag'-'$mon'"} /^}/ {node=""}' >> $filePath/mon/new-tmshcommands
  done
  echo -ne "\r# finished checking for nodes that use renamed monitors                               \n"

  # pools
  echo -e "\n# point pools at new monitors" >> $filePath/mon/new-tmshcommands
  awk '/^ltm monitor/ {gsub (/\/Common\//,"",$4);print $3,$4}' $filePath/mon/orig-monitors | while read type mon; do
    echo -ne "\r# checking for pools that use monitor $type $mon                              "
    tmsh list ltm pool monitor | awk '/^ltm pool/ && !/(\/Common\/|).*\.app\// {gsub (/\/Common\//,"",$3); pool=$3} /^    monitor (.*{ |)'$mon'( |$| })/ {if (pool != "") print "tmsh modify ltm pool",pool,"monitor '$tag'-'$mon'"} /^}/ {pool=""}' >> $filePath/mon/new-tmshcommands
  done
  echo -ne "\r# finished checking for pools that use renamed monitors                               \n"

  awk '/^tmsh/' $filePath/mon/new-tmshcommands | while read cmd; do
    returnStr="Updating Node and Pool monitors: $cmd"
    echo -ne "\r$returnStr                              "
    log_entry

    $cmd
  done
  echo -ne "\rUpdating Node and Pool monitors: complete                                                                  \n"
  returnStr="Updating Node and Pool monitors: complete"
  log_entry

  # remove old monitors from config
  awk '/^ltm monitor/ {gsub (/\/Common\//,"",$4);print $3,$4}' $filePath/mon/orig-monitors | while read type mon; do
    cmd="tmsh delete ltm monitor $type $mon"
    returnStr="Removing old monitors: $cmd"
    echo -ne "\r$returnStr                              "
    log_entry
    
    $cmd
  done
  echo -ne "\rRemoving old monitors: complete                                              \n"
  returnStr="Removing old monitors: complete"
  log_entry
else
  returnStr="Monitors: no user defined monitors found in config. Skipping monitors"
  echo $returnStr
  log_entry
fi
  
##########################
# SSL Profiles
##########################
mkdir $filePath/ssl 2>/dev/null

# get all certs and key files copied to our filepath temporarily
awk '/^sys file ssl-(cert|key)/,/^}/' $srcConfig | awk '/^sys file ssl-(cert|key)/ {gsub (/\/Common\//,"",$4); name=$4} /cache-path/ {file=$2} /^}/ {print name,file}' | while read oldName file; do
  returnStr="SSL Profiles: copying cert/key file $oldName to $filePath/ssl/$tag-$oldName"
  log_entry
  if [[ "file" != "$tag"* ]] ; then
    # only for certs and keys that are not already prepended with the tag
    cp $file $filePath/ssl/$tag-$oldName
    # record original ssl filenames
    echo $oldName >> $filePath/ssl/orig-filenames
  fi 
done

if [ -f $filePath/ssl/orig-filenames ] && [ "$(cat $filePath/ssl/orig-filenames | wc -l)" -gt 0 ] ; then

  # install new ssl certs and keys with tag in name
  for file in $(ls  $filePath/ssl/ | awk '/.*\.(crt|key)/'); do
    if [[ "$file" == *"crt" ]] ; then
      cmd="tmsh install sys crypto cert $file from-local-file $filePath/ssl/$file"
    else
      cmd="tmsh install sys crypto key $file from-local-file $filePath/ssl/$file"
    fi
    
    returnStr="SSL Profiles: Installing cert/keyfile - $cmd"
    echo -ne "\r$returnStr                              "
    log_entry
    $cmd
    
  done
  echo -ne "\rInstalling cert/keyfile: complete                                                                                                                                      \n"

  # create config for new client-ssl profiles
  # get list of client-ssl profiles that need to be modified
  for file in $(cat $filePath/ssl/orig-filenames); do
    tmsh list ltm profile client-ssl cert key chain | awk '/^ltm profile/ && !/(\/Common\/|).*\.app\// {prof=$4} /^    (cert|key|chain) '$file'( |$)/ {if (prof) print prof}'
  done | sort -u >> $filePath/ssl/affected-clientssl

  # create config file for new client-ssl profiles
  for prof in $(cat $filePath/ssl/affected-clientssl); do
    awk '/^ltm profile client-ssl \/Common\/'$prof' {/,/^}/ {gsub (/\/'$prof' {/,"/'$tag'-'$prof' {"); print}' $srcConfig
    returnStr="SSL Profiles: making config for new client-ssl profile $tag-$prof"
    log_entry
  done > $filePath/ssl/new-clientssl

  # update refs to old certnames for new client-ssl profiles
  for file in $(cat $filePath/ssl/orig-filenames); do
    sed -i 's/\/Common\/'$file'$/\/Common\/'$tag'-'$file'/' $filePath/ssl/new-clientssl
  done

  # load new client-ssl config
  returnStr="Loading new client-ssl config"
  echo $returnStr
  log_entry

  tmsh load sys config file $filePath/ssl/new-clientssl merge

  # update virtual servers with new client-ssl profiles
  echo "# update virtual servers with new client-ssl profiles" > $filePath/ssl/vs-tmshcommands
  for prof in $(cat $filePath/ssl/affected-clientssl); do
    tmsh list ltm virtual profiles | awk '/^ltm virtual/ && !/(\/Common\/|).*\.app\// {vs=$3} / '$prof' {/ {if (vs) print vs} /^}/ {vs=""}' | while read vs; do
      profiles=$(tmsh list ltm virtual $vs profiles | awk '/^        .* {/,/^        }/' | awk '/ .* {/ {gsub (/'$prof'/,"'$tag'-'$prof'",$1); prof=$1} / context / {ctx=$2} /^        }/ {printf "%s { context %s } ", prof,ctx}')

      echo "tmsh modify ltm virtual $vs profiles replace-all-with { $profiles }" >> $filePath/ssl/vs-tmshcommands
    done
  done

  awk '/^tmsh/'  $filePath/ssl/vs-tmshcommands | while read cmd; do
    returnStr="SSL Profiles: Updating virtual servers with new client-ssl profiles"
    echo -ne "\r$returnStr                              "
    log_entry
    $cmd
  done
  echo -ne "\rSSL Profiles: Updating virtual servers with new client-ssl profiles - complete\n"

  # remove legacy client-ssl profiles, certs, and keys
  # client-ssl profiles
  for prof in $(cat $filePath/ssl/affected-clientssl); do
    echo "tmsh delete ltm profile client-ssl $prof" >> $filePath/ssl/sslprof-tmshcommands
  done

  cat $filePath/ssl/sslprof-tmshcommands | while read cmd; do
    returnStr="SSL Profiles: Removing old ssl profiles - $cmd"
    echo -ne "\r$returnStr                              "
    log_entry
    $cmd
  done
  echo -ne "\rSSL Profiles: Removing old ssl profiles - complete                                                                       \n"

  # certs and keys
  cp ssl/orig-filenames ssl/del-filenames
  for file in $(tmsh list ltm profile client-ssl *.app/* cert key chain | awk '/^    (cert|key|chain)/ {if ($2 != "none") print $2}'); do 
    sed -i 's/'$file'//' ssl/del-filenames
  done

  for file in $(cat $filePath/ssl/del-filenames); do
    if [[ "$file" == *"crt" ]] ; then
      cmd="tmsh delete sys crypto cert $file"
    else
      cmd="tmsh delete sys crypto key $file"
    fi
    returnStr="SSL Profiles: deleting cert/keyfile - $cmd"
    echo -ne "\r$returnStr                                          "
    log_entry
    $cmd
  done
  echo -ne "\rSSL Profiles: deleting cert/keyfile - complete                                                                         \n"

else
  returnStr="SSL-profiles: no user defined ssl-certificates found in config. Skipping ssl-profiles"
  echo $returnStr
  log_entry
fi
  
##########################
# iRules
##########################

# create config for new iRules with tag in name

for rule in $(awk '/^ltm rule / !/\/Common\/'$tag'-/ && !/(\/Common\/|).*\.app\// {print $3}' $srcConfig); do
  tmsh list ltm rule $rule 
done > $filePath/rul/orig-irules

if [ -f $filePath/rul/orig-irules ] && [ "$(cat $filePath/rul/orig-irules | wc -l)" -gt 0 ] ; then

  awk '/^ltm rule/ && !/(\/Common\/|).*\.app\//,/^ltm/ && !/rule/ {if ($0 !~ /^ltm/ || /^ltm rule/) print}' $srcConfig > $filePath/rul/orig-irules
  cp $filePath/rul/orig-irules $filePath/rul/new-irules

  for rule in $(awk '/^ltm rule/ {gsub (/\/Common\//,"",$3); print $3}' $filePath/rul/orig-irules); do
    sed -i 's/^ltm rule \/Common\/'$rule' {/ltm rule \/Common\/'$tag'-'$rule' {/' $filePath/rul/new-irules
  done

  # load new iRule config
  returnStr="iRules: loading new iRule config"
  echo $returnStr
  log_entry

  tmsh load sys config file $filePath/rul/new-irules merge

  # update virtual servers with new iRules
  for rule in $(awk '/^ltm rule/ {gsub (/\/Common\//,"",$3);print $3}' $filePath/rul/orig-irules) ; do
    echo -ne "\r# checking for VSes that use iRule $rule                                                                                                "
    for vs in $(tmsh list ltm virtual rules | awk '/^ltm virtual/ && !/(\/Common\/|).*\.app\// {gsub (/\/Common\//,"",$3); vs=$3} /^        '$rule'( |$)/ {if (vs)print vs} /^}/ {vs=""}'); do
      rules=$(tmsh list ltm virtual $vs rules | awk '/^        .*( |$)/ {gsub (/'$rule'/,"'$tag'-'$rule'",$1); rule=$1} /^    }/ {printf "%s ", rule}')
      cmd="tmsh modify ltm virtual $vs rules { $rules }"
      returnStr="iRules: updating virtual $vs - $cmd"
      echo -ne "\r$returnStr                              "
      log_entry

      $cmd
    done
  done
  echo -ne "\riRules: finished updating virtual servers                                                                                                \n"

  # remove old iRules
  awk '/^ltm rule/ {print $3}' rul/orig-irules > rul/del-irules
  for file in $(tmsh list ltm virtual *.app/* rules | awk '/^        .*/ {print $1}'); do 
    sed -i 's/'$file'//' rul/del-irules
  done

  for rule in $(awk '/^ltm rule/ {gsub (/\/Common\//,"",$3);print $3}' $filePath/rul/del-irules) ; do
    cmd="tmsh delete ltm rule $rule"
    
    returnStr="iRules: deleting iRule $rule - $cmd"
    echo -ne "\r$returnStr                              "
    log_entry

    $cmd
  done
  echo -ne "\riRules: finished deleting old iRules                                                                                                     \n"

else
  returnStr="iRules: no user defined iRules found in config. Skipping iRules"
  echo $returnStr
  log_entry
  
fi
  
  
# save config
returnStr="Object Rename Complete: saving config"
log_entry
tmsh save sys config

# take post-change stats
returnStr="Obtaining post-change pool member stats"
echo $returnStr
log_entry
tmsh show ltm pool field-fmt members | awk --posix  '/node-name/ {mem=$2} /addr/ {mbrAddr=$2} / port / {mbrPort=$2} /^ {12}status.availability-state/ {avStat=$2} /^ {12}status.enabled-state/ {enstate=$2} /^ {12}pool-name/ {pname=$2} /^ {8}}/ {print pname,mem,mbrAddr,mbrPort,avStat,enstate}' | sort -k 3,4 -k 1,1 > $filePath/postchange-stats

# diff pre and post change stats
echo "Diff of Pre and Post change pool member stats:"
diff -w $filePath/prechange-stats $filePath/postchange-stats | sed -e 's/^</Before -/;s/^>/After -/'
