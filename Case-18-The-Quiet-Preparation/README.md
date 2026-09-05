# Case #18: The Quiet Preparation

**Difficulty:** 🔴 Advanced &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~1 day

> Not to be confused with [Case #05](../Case-05-Backup-Siege/), where backup sabotage was
> discovered *after* the ransomware already hit. This case catches the same style of pre-attack
> reconnaissance *before* any encryption happens at all.

## 🚨 Scenario Overview
A threat-hunting sweep, not an alert, surfaced something odd: `vssadmin list shadows` and backup
software queries run across four unrelated hosts overnight — nothing encrypted, nothing broken, just
a lot of quiet looking around.

## 🕵️ First Theory — Scheduled Maintenance
Shadow-copy and backup queries are routine on patch nights. The first check was simple: does this
match a scheduled maintenance window? It didn't — no ticket, no change record, four hosts nobody
had flagged for anything that night.

## 🔦 The Detail That Broke It
```spl
index=win_logs sourcetype=security_events
| search CommandLine="*vssadmin*" OR CommandLine="*shadowcopy*"
| stats values(host) as hosts by user
```

All four hosts were touched by the **same account** — an account that had triggered a phishing alert
three days earlier, closed at the time with the note "user reports they did not click."

## 🔎 The Real Investigation
Endpoint telemetry told a different story than the user's own recollection: a scheduled task had been
silently created on that user's machine within minutes of the phishing email arriving — the click had
happened, whether the user remembered it or not. Everything since then had been quiet
reconnaissance: enumerating shadow copies and backup infrastructure across the network, the
well-documented preparation phase that precedes ransomware deployment, not the deployment itself.

## 🛠️ Mitigation & Hardening
* Disabled the compromised account and isolated all four touched hosts immediately.
* Hunted for and removed the scheduled-task persistence mechanism.
* Restricted `vssadmin`/`wbadmin` execution to admin accounts only, with logging and alerting on use.
* Changed policy: a user's self-report is never sufficient to close a phishing alert — endpoint
  telemetry must confirm no execution occurred before closing.

## 📂 Repository Artifacts
* `queries.spl` — Splunk query surfacing shadow-copy/backup discovery commands across multiple hosts.

## 📝 Case Notes
Nothing was encrypted, and that's exactly why this case mattered — it was caught during the
reconnaissance phase because someone went hunting instead of waiting for an alert. The earlier
"closed, user says no" ticket was the actual root cause, three days before anyone noticed.
