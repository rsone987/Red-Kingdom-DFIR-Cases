# Case #23: The Insider Who Wasn't

**Difficulty:** 🔴 Advanced &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~3 days

> A different root cause than [Case #02](../Case-02-Ghost-in-the-Query/): that case was a stolen
> credential with excess privilege. This one is a machine acting entirely on its own, with the account
> owner never involved at all.

## 🚨 Scenario Overview
An alert fired on textbook insider-threat behavior: an employee's account accessed a sensitive
folder after hours, compressed the contents into a large archive, and uploaded it to an external
address. Every individual step matched the pattern HR training slides use as the canonical example.

## 🕵️ First Theory — Malicious Insider
The pattern was clean enough that the case moved toward HR involvement almost immediately —
after-hours sensitive access, archive creation, external transfer is about as textbook as it gets.

## 🔦 The Detail That Broke It
```bash
$ badge-query --user jdoe --date 2026-09-12
Last badge swipe: 17:32 (departure) — no further entries.
```

The archive was created at 23:47. The employee had left the building over six hours earlier, and no
VPN session existed for their known devices during that window either. Whatever did this, it wasn't
them, physically or remotely.

## 🔎 The Real Investigation
Endpoint forensics found a scheduled task, disguised with a name resembling a legitimate backup
utility, installed **weeks earlier** — the leftover of an unrelated malware infection that an earlier
ticket had marked "resolved" after the AV agent quarantined one detected file. The quarantine had
caught the initial dropper, but not the persistence mechanism it had already planted. The archive-
and-upload behavior was that mechanism running exactly as designed, entirely independent of the
employee it happened to be sitting on.

## 🛠️ Mitigation & Hardening
* Fully reimaged the endpoint — a single quarantined file was never sufficient remediation.
* Retroactively reviewed every "resolved" malware ticket from the same period for the same
  incomplete-cleanup gap.
* Cleared the employee's record explicitly in the HR case file, with the technical evidence attached.
* Updated remediation policy: closing a malware ticket now requires confirming no scheduled tasks,
  registry run-keys, or other persistence remain — not just that the flagged file was quarantined.

## 📂 Repository Artifacts
* `queries.spl` — Splunk query correlating archive-creation-and-egress events with an absence of
  matching badge or VPN presence for the account owner.

## 📝 Case Notes
The evidence against the employee was real — it just wasn't evidence of anything the employee did.
The actual failure was a malware ticket closed one step too early, weeks before anyone noticed.
