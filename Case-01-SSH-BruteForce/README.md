# Case #01: The Midnight Phantom — SSH Brute-Force Triage

**Difficulty:** 🟢 Beginner &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~3 hours

## 🚨 Scenario Overview
02:14 AM. The Red Kingdom's SIEM lit up: over 50,000 failed SSH login attempts against the core
production servers in under six minutes. The kind of number that makes you sit up straight.

## 🕵️ First Theory — And Why It Was Too Simple
My first read: a single attacker, brute-forcing one exposed account. Block the source IP, close the
ticket, back to sleep. I almost did exactly that.

```spl
index=linux_logs sourcetype=syslog process=sshd "Failed password"
| stats count by src_ip, user
| sort - count
```

The results didn't match a "single attacker" story at all — the failed attempts were spread across
**dozens of source IPs**, all targeting the same handful of default local usernames within seconds of
each other. No human types that fast, and no single attacker owns that many addresses.

## 🔎 The Real Picture
This wasn't one intruder — it was a **distributed botnet**, running the exact same password list
against every server in the fleet simultaneously. DTEX confirmed the traffic signature matched known
botnet brute-force behavior, not a targeted, manual attack.

## 🔦 Root Cause
The real problem wasn't the botnet — botnets are background noise on the internet. The real problem
was that our servers still accepted **password authentication** as a fallback, which is the only reason
a botnet's blind guessing had any chance of working at all.

## 🛠️ Mitigation & Hardening
* Disabled password authentication completely across `/etc/ssh/sshd_config`.
* Enforced Ed25519 SSH key-pair authentication fleet-wide.
* Reloaded `sshd` to terminate every in-progress botnet connection attempt.

## 📂 Repository Artifacts
* `queries.spl` — Splunk query used to detect and characterize the attack pattern.
* `hardening_script.sh` — Automation script that hardens `sshd` to key-only authentication.

## 📝 Case Notes
The scale of the alert made it *look* hard. It wasn't — the fix was one configuration line away the
whole time. Not every case is a mystery. Some are just noise with an easy off-switch, if you know
where it is.
