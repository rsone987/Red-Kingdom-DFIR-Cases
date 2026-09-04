# Case #05: Backups Under Siege — The Restore That Failed

**Difficulty:** 🔴 Advanced &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~4 days

## 🚨 Scenario Overview
A file server started encrypting itself in real time — classic ransomware. The team's first move was
the textbook one: isolate the host, confirm backups exist, restore, move on.

## 🕵️ First Theory — "We Have Backups, We're Fine"
Backup jobs had reported **success** every night for the past three weeks. This looked like a
contained, recoverable incident — annoying, not catastrophic.

## 🔦 The Detail That Broke That Confidence
The restore test failed. Not partially — completely. The "successful" backups were themselves
encrypted.

```bash
$ restic check --read-data
error: repository contains 340 corrupted pack files
```

Backups don't spontaneously corrupt. Something had been inside the backup infrastructure long
before tonight's visible attack.

## 🔎 The Real Investigation
Backup server access logs told the actual story: a compromised service account had been
enumerating and selectively overwriting backup repositories for **weeks**, quietly replacing clean
archives with encrypted ones while every job still reported a normal, successful exit code.

```spl
index=backup_logs sourcetype=backup_audit user=svc_backup
| stats count by action, repo_name
| where action="delete" OR action="overwrite"
```

The visible ransomware event wasn't the attack — it was the **finale**. The real operation had been
quietly poisoning every safety net for weeks before pulling the trigger on the file server everyone
actually noticed.

## 🔦 Root Cause
Two structural failures made this possible: every backup copy lived online and writable (no offline,
air-gapped copy — a violation of the 3-2-1 rule), and the backup service account had far more
write/delete privilege than a backup job should ever need.

## 🛠️ Mitigation & Hardening
* Enforced the **3-2-1 backup rule** — at least one copy offline and disconnected from the network.
* Moved to immutable/WORM-backed storage for the offline copy.
* Re-scoped the backup service account to write-only, append-only access — it can no longer delete
  or overwrite existing archives.
* Instituted monthly restore testing as a standing requirement, not an afterthought.

## 📂 Repository Artifacts
* `backup_integrity_check.sh` — Automated restore-test script run against a random sample monthly.
* `queries.spl` — Splunk query surfacing anomalous delete/overwrite activity from the backup account.

## 📝 Case Notes
A backup you haven't test-restored isn't a backup — it's an assumption. This one cost four days to
untangle because the assumption had been quietly false for three weeks before anyone needed it.
