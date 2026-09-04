# Case #09: The Golden Ticket — A Domain Admin Who Was Never There

**Difficulty:** ⚫ Expert &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~5 days

## 🚨 Scenario Overview
A Domain Admin account performed sensitive actions on three different servers within eleven
seconds of each other. No VPN. No physical possibility of one person doing that from one console.

## 🕵️ First Theory — Phished Credentials
The standard response: assume the account is compromised, force a password reset, re-enroll MFA,
close it out.

## 🔦 The Detail That Broke That Response
The sessions kept working. **After** the password reset. That shouldn't be possible — a password
reset invalidates active sessions, full stop, in any normal compromise.

## 🔎 The Real Investigation
```spl
index=win_logs EventCode=4768 OR EventCode=4769
| table _time, Account_Name, Ticket_Options, Ticket_Encryption_Type, Ticket_Lifetime
```

Ticket lifetimes came back at **10 years**. Domain policy caps Kerberos ticket life at 10 hours. The
encryption type was also inconsistent with what the domain's policy actually issues.

This is the signature of a **Golden Ticket attack**: at some earlier point, the attacker had extracted
the password hash of the **krbtgt** account — the account that signs every Kerberos ticket in the
domain — and used it to forge tickets directly. A forged ticket doesn't check in with a live session, an
active password, or MFA at all. It just needs to be signed with a key the domain trusts, and the
krbtgt key signs *everything*.

## 🔦 Root Cause
The krbtgt account's password had **never been rotated since the domain was created**, years
earlier. An earlier, smaller compromise — never fully traced — had been enough to extract that one
hash, and from that point forward the attacker held a skeleton key that no password reset, anywhere
else in the domain, could ever touch.

## 🛠️ Mitigation & Hardening
* Reset the krbtgt password **twice**, following Microsoft's required double-reset procedure, to fully
  invalidate every ticket forged from the old hash.
* Audited and drastically reduced Domain Admins group membership.
* Instituted scheduled krbtgt rotation as standing domain policy, not a one-time incident response.
* Enabled Kerberoasting and ticket-anomaly detection rules going forward.

## 📂 Repository Artifacts
* `kerberos_ticket_audit.spl` — Splunk query surfacing tickets with abnormal lifetime/encryption.
* `krbtgt_rotation_checklist.md` — Standing procedure for safe krbtgt password rotation.

## 📝 Case Notes
No amount of resetting the visible account would have ended this — the actual key had never been
touched. The hardest incidents aren't the ones with a clever attacker; they're the ones where a
foundational piece of hygiene was skipped once, years ago, and nobody circled back.
