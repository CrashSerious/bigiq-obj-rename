<html>

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1252">
<meta name=Generator content="Microsoft Word 15 (filtered)">
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:Wingdings;
	panose-1:5 0 0 0 0 0 0 0 0 0;}
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:"Calibri Light";
	panose-1:2 15 3 2 2 2 4 3 2 4;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin-top:0in;
	margin-right:0in;
	margin-bottom:8.0pt;
	margin-left:0in;
	line-height:107%;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
a:link, span.MsoHyperlink
	{color:#0563C1;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{color:#954F72;
	text-decoration:underline;}
p.MsoListParagraph, li.MsoListParagraph, div.MsoListParagraph
	{margin-top:0in;
	margin-right:0in;
	margin-bottom:8.0pt;
	margin-left:.5in;
	line-height:107%;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
p.MsoListParagraphCxSpFirst, li.MsoListParagraphCxSpFirst, div.MsoListParagraphCxSpFirst
	{margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:.5in;
	margin-bottom:.0001pt;
	line-height:107%;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
p.MsoListParagraphCxSpMiddle, li.MsoListParagraphCxSpMiddle, div.MsoListParagraphCxSpMiddle
	{margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:.5in;
	margin-bottom:.0001pt;
	line-height:107%;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
p.MsoListParagraphCxSpLast, li.MsoListParagraphCxSpLast, div.MsoListParagraphCxSpLast
	{margin-top:0in;
	margin-right:0in;
	margin-bottom:8.0pt;
	margin-left:.5in;
	line-height:107%;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
.MsoChpDefault
	{font-family:"Calibri",sans-serif;}
.MsoPapDefault
	{margin-bottom:8.0pt;
	line-height:107%;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
	{page:WordSection1;}
 /* List Definitions */
 ol
	{margin-bottom:0in;}
ul
	{margin-bottom:0in;}
-->
</style>

</head>

<body lang=EN-US link="#0563C1" vlink="#954F72">

<div class=WordSection1>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><b><span style='font-size:16.0pt'>objRename script</span></b></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>Objective: Rename
user defined monitors, client-ssl profiles (and related certs and keys), and
iRules with specified prefix in preparation for a device import into BIG-IQ.</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>&nbsp;</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;text-indent:
.25in;line-height:normal'><span style='font-family:"Calibri Light",sans-serif'>Prep-work</span></p>

<p class=MsoListParagraphCxSpFirst style='margin-bottom:0in;margin-bottom:.0001pt;
text-indent:-.25in;line-height:normal'><span style='font-family:Symbol'>·<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-family:"Calibri Light",sans-serif'>Verify HA is
synched</span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-bottom:0in;margin-bottom:
.0001pt;text-indent:-.25in;line-height:normal'><span style='font-family:Symbol'>·<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-family:"Calibri Light",sans-serif'>Save running
config to file</span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-bottom:0in;margin-bottom:
.0001pt;text-indent:-.25in;line-height:normal'><span style='font-family:Symbol'>·<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-family:"Calibri Light",sans-serif'>Backup
current config</span></p>

<p class=MsoListParagraphCxSpLast style='margin-bottom:0in;margin-bottom:.0001pt;
text-indent:-.25in;line-height:normal'><span style='font-family:Symbol'>·<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-family:"Calibri Light",sans-serif'>Take
snapshot of pre-change pool member stats (for post change validation)</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;text-indent:
.25in;line-height:normal'><span style='font-family:"Calibri Light",sans-serif'>Monitors
</span></p>

<p class=MsoListParagraphCxSpFirst style='margin-bottom:0in;margin-bottom:.0001pt;
text-indent:-.25in;line-height:normal'><span style='font-family:Symbol'>·<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-family:"Calibri Light",sans-serif'>Rename user
defined monitors</span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-bottom:0in;margin-bottom:
.0001pt;text-indent:-.25in;line-height:normal'><span style='font-family:Symbol'>·<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-family:"Calibri Light",sans-serif'>Update
objects referring to renamed monitors with new monitor names</span></p>

<p class=MsoListParagraphCxSpLast style='margin-bottom:0in;margin-bottom:.0001pt;
text-indent:-.25in;line-height:normal'><span style='font-family:Symbol'>·<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-family:"Calibri Light",sans-serif'>Delete old
(unused) monitors</span></p>

<p class=MsoNormal style='margin-top:0in;margin-right:0in;margin-bottom:0in;
margin-left:.25in;margin-bottom:.0001pt;line-height:normal'><span
style='font-family:"Calibri Light",sans-serif'>SSL-Profiles, Certs, and Keys</span></p>

<p class=MsoListParagraphCxSpFirst style='margin-bottom:0in;margin-bottom:.0001pt;
text-indent:-.25in;line-height:normal'><span style='font-family:Symbol'>·<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-family:"Calibri Light",sans-serif'>Obtain user
defined certs and keys from BIG-IP.</span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-bottom:0in;margin-bottom:
.0001pt;text-indent:-.25in;line-height:normal'><span style='font-family:Symbol'>·<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-family:"Calibri Light",sans-serif'>Re-install
certs and keys with new names</span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-bottom:0in;margin-bottom:
.0001pt;text-indent:-.25in;line-height:normal'><span style='font-family:Symbol'>·<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-family:"Calibri Light",sans-serif'>Rename SSL
profiles and update with new cert and key names</span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-bottom:0in;margin-bottom:
.0001pt;text-indent:-.25in;line-height:normal'><span style='font-family:Symbol'>·<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-family:"Calibri Light",sans-serif'>Update
objects referring to renamed SSL-profiles with new profile names</span></p>

<p class=MsoListParagraphCxSpLast style='margin-bottom:0in;margin-bottom:.0001pt;
text-indent:-.25in;line-height:normal'><span style='font-family:Symbol'>·<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-family:"Calibri Light",sans-serif'>Delete old
(unused) SSL profiles, certs, and keys.</span></p>

<p class=MsoNormal style='margin-top:0in;margin-right:0in;margin-bottom:0in;
margin-left:.25in;margin-bottom:.0001pt;line-height:normal'><span
style='font-family:"Calibri Light",sans-serif'>iRules</span></p>

<p class=MsoListParagraphCxSpFirst style='margin-bottom:0in;margin-bottom:.0001pt;
text-indent:-.25in;line-height:normal'><span style='font-family:Symbol'>·<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-family:"Calibri Light",sans-serif'>Obtain user
defined iRules from BIG-IP</span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-bottom:0in;margin-bottom:
.0001pt;text-indent:-.25in;line-height:normal'><span style='font-family:Symbol'>·<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-family:"Calibri Light",sans-serif'>Rename
iRules</span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-bottom:0in;margin-bottom:
.0001pt;text-indent:-.25in;line-height:normal'><span style='font-family:Symbol'>·<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-family:"Calibri Light",sans-serif'>Update
objects referring to renamed iRules</span></p>

<p class=MsoListParagraphCxSpLast style='margin-bottom:0in;margin-bottom:.0001pt;
text-indent:-.25in;line-height:normal'><span style='font-family:Symbol'>·<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-family:"Calibri Light",sans-serif'>Delete old
(unused) iRules</span></p>

<p class=MsoNormal style='margin-top:0in;margin-right:0in;margin-bottom:0in;
margin-left:.25in;margin-bottom:.0001pt;line-height:normal'><span
style='font-family:"Calibri Light",sans-serif'>Post-change</span></p>

<p class=MsoListParagraphCxSpFirst style='margin-bottom:0in;margin-bottom:.0001pt;
text-indent:-.25in;line-height:normal'><span style='font-family:Symbol'>·<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-family:"Calibri Light",sans-serif'>Save running
config to file</span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-bottom:0in;margin-bottom:
.0001pt;text-indent:-.25in;line-height:normal'><span style='font-family:Symbol'>·<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-family:"Calibri Light",sans-serif'>Take
snapshot of post-change pool member stats</span></p>

<p class=MsoListParagraphCxSpLast style='margin-bottom:0in;margin-bottom:.0001pt;
text-indent:-.25in;line-height:normal'><span style='font-family:Symbol'>·<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</span></span><span style='font-family:"Calibri Light",sans-serif'>Compare pre-change
and post-change pool member stats</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>&nbsp;</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><b><span style='font-size:12.0pt;font-family:"Calibri Light",sans-serif'>Implementation</span></b></p>

<p class=MsoListParagraph style='margin-bottom:0in;margin-bottom:.0001pt;
text-indent:-.25in;line-height:normal'><span style='font-family:"Calibri Light",sans-serif'>1.<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span
style='font-family:"Calibri Light",sans-serif'>On the BIG-IP, create a
directory to work from like /var/tmp/objRename</span></p>

<p class=MsoNormal style='margin-top:0in;margin-right:0in;margin-bottom:0in;
margin-left:.5in;margin-bottom:.0001pt;line-height:normal'><span
style='font-family:"Calibri Light",sans-serif'>mkdir /var/tmp/objRename</span></p>

<p class=MsoNormal style='margin-top:0in;margin-right:0in;margin-bottom:0in;
margin-left:.5in;margin-bottom:.0001pt;line-height:normal'><span
style='font-family:"Calibri Light",sans-serif'>&nbsp;</span></p>

<p class=MsoNormal style='margin-top:0in;margin-right:0in;margin-bottom:0in;
margin-left:.5in;margin-bottom:.0001pt;line-height:normal'><span
style='font-family:"Calibri Light",sans-serif'>If the directory is different
than above, change the filePath in the script accordingly</span></p>

<p class=MsoNormal style='margin-top:0in;margin-right:0in;margin-bottom:0in;
margin-left:.5in;margin-bottom:.0001pt;line-height:normal'><span
style='font-family:"Calibri Light",sans-serif'>filePath=&quot;/var/tmp/objRename/&quot;</span></p>

<p class=MsoNormal style='margin-top:0in;margin-right:0in;margin-bottom:0in;
margin-left:.5in;margin-bottom:.0001pt;line-height:normal'><span
style='font-family:"Calibri Light",sans-serif'>&nbsp;</span></p>

<p class=MsoListParagraphCxSpFirst style='margin-bottom:0in;margin-bottom:.0001pt;
text-indent:-.25in;line-height:normal'><span style='font-family:"Calibri Light",sans-serif'>2.<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span
style='font-family:"Calibri Light",sans-serif'>Copy the script to the working
directory and change permissions so we can execute it</span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-bottom:0in;margin-bottom:
.0001pt;line-height:normal'><span style='font-family:"Calibri Light",sans-serif'>Chmod
755 /var/tmp/objRename/objRename.sh</span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-bottom:0in;margin-bottom:
.0001pt;line-height:normal'><span style='font-family:"Calibri Light",sans-serif'>&nbsp;</span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-bottom:0in;margin-bottom:
.0001pt;text-indent:-.25in;line-height:normal'><span style='font-family:"Calibri Light",sans-serif'>3.<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </span></span><span
style='font-family:"Calibri Light",sans-serif'>Run the script with a single
command line argument for the tag string that will be prepended to the renamed
objects (monitors, client-ssl profiles, certs, keys, and iRules) in preparation
for import into BIG-IQ.</span></p>

<p class=MsoListParagraphCxSpMiddle style='margin-bottom:0in;margin-bottom:
.0001pt;line-height:normal'><span style='font-family:"Calibri Light",sans-serif'>Example:</span></p>

<p class=MsoListParagraphCxSpLast style='margin-bottom:0in;margin-bottom:.0001pt;
line-height:normal'><span style='font-family:"Calibri Light",sans-serif'>./objRename.sh
SK-PrdInt</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>&nbsp;</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><b><span style='font-size:12.0pt;font-family:"Calibri Light",sans-serif'>Post
Implementation</span></b></p>

<p class=MsoListParagraph style='margin:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>After the script
completes, there will be files and directories created in the working
directory. The following files are created and can be used for validation or
trouble shooting.</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>        <b>objRename.log</b>
– log file showing actions taken and timestamps which can be correlated to the
ltm and audit logs on the BIG-IP</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>        <b>postchange-stats,
prechange-stats</b> – status of pool members taken before and after change for
validation</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>        </span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>        <b>mon/new-monitors
</b>– config file containing renamed monitors for loading onto BIG-IP</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>        <b>mon/orig-monitors</b>
– config file containing original monitors taken prior to change</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>        <b>mon/new-tmshcommands</b>
– file of tmsh commands for modifying nodes and pools to refer to renamed
monitors</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>&nbsp;</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>        <b>ssl/orig-filenames</b>
– list of ssl certs and keys from BIG-IP which will be renamed.</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>        <b>ssl/[cert
and key files]</b> – renamed ssl certs and keys to be installed onto BIG-IP</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>        <b>ssl/affected-clientssl</b>
– client ssl profiles that need to be renamed</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>        <b>ssl/new-clientssl</b>
– config file containing renamed client-ssl profiles and new cert/key
references</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>        <b>ssl/vs-tmscommands</b>
– file containing tmsh commands to update virtual servers with renamed
client-ssl profiles</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>        <b>ssl/sslprof-tmshcommands</b>
– file with tmsh commands to delete old (unused) client-ssl profiles</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>        </span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>        <b>rul/orig-irules</b>
– config file containing iRules from BIG-IP that will be renamed</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>        <b>rul/new-irules</b>
– config file containing renamed iRules</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>&nbsp;</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>As the script
finishes, it will take another snapshot of current pool members stats on the
BIG-IP for comparison to the pre-change snapshot that was taken.  If there are
any differences you will see output like the example below which can be
followed up to determine cause.</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>&nbsp;</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif;color:#385623'>Obtaining
post-change pool member stats</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif;color:#385623'>Diff
of Pre and Post change pool member stats:</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif;color:#385623'>478,480c478,480</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif;color:#385623'>Before
- vltimagent-pool-16231 vltimagent 10.65.14.57 16231 <b>offline</b> enabled</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif;color:#385623'>Before
- sdipim-pool-16232 vltimagent 10.65.14.57 16232 <b>offline</b> enabled</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif;color:#385623'>Before
- vltimagentad-pool-45580 vltimagent 10.65.14.57 45580 <b>offline</b> enabled</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif;color:#385623'>---</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif;color:#385623'>After
- vltimagent-pool-16231 vltimagent 10.65.14.57 16231 <b>unknown</b> enabled</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif;color:#385623'>After
- sdipim-pool-16232 vltimagent 10.65.14.57 16232 <b>unknown</b> enabled</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif;color:#385623'>After
- vltimagentad-pool-45580 vltimagent 10.65.14.57 45580 <b>unknown</b> enabled</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>&nbsp;</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><b><span style='font-size:12.0pt;font-family:"Calibri Light",sans-serif'>Backout
Procedure</span></b></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>Before changes are
made, the script generates SCF and UCS files for backout purposes. The files
are located in /var/local/scf/ and /var/local/ucs/ respectively.</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>&nbsp;</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>SCF and UCS
filename format: pre-change_<b><span style='color:#C00000'>[big-ip-hostname]</span></b>_<b><span
style='color:#C00000'>[yyyy-mm-dd]</span></b></span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>&nbsp;</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>Restoring from the
SCF file</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span class=MsoHyperlink><span style='font-family:"Calibri Light",sans-serif'><a
href="https://support.f5.com/csp/article/K13408">https://support.f5.com/csp/article/K13408</a></span></span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>&nbsp;</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>Restoring from the
UCS file</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span class=MsoHyperlink><span style='font-family:"Calibri Light",sans-serif'><a
href="https://support.f5.com/csp/article/K13132">https://support.f5.com/csp/article/K13132</a></span></span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>&nbsp;</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>&nbsp;</span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-family:"Calibri Light",sans-serif'>&nbsp;</span></p>
</div>
</body>
</html>
