# Case #16: The Stolen Session

**Difficulty:** 🟡 Intermediate &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~2 days

## 🚨 Scenario Overview
An "impossible travel" alert fired: the same employee account was active in two countries within the
same hour. No brute-force pattern anywhere near the event — every login on record looked clean.

## 🕵️ First Theory — A VPN Artifact
No failed logins, no password-spray pattern — the leading theory was a mislabeled exit node: the
employee's VPN client routing through a foreign endpoint, producing a false "impossible travel" flag.

## 🔦 The Detail That Broke It
```spl
index=idp_logs user=jsmith
| table _time, session_id, device_fingerprint, src_country
```

Both "sessions" shared the **exact same session ID** — but two completely different device
fingerprints and browsers. A VPN artifact would still be one continuous session on one device. This
was the same token, active from two unrelated machines simultaneously.

## 🔎 The Real Investigation
There was no second authentication event at all — no new login, no MFA prompt, nothing. The
attacker never needed the password. They had a **stolen session token**, replayed directly from a
different device, which is functionally equivalent to walking in through an already-open door.

Endpoint telemetry from three days earlier explained where it came from: an infostealer alert on the
user's laptop, closed at the time as "quarantined, no further action," had in fact already exfiltrated
active browser session cookies before the AV caught the payload itself.

## 🛠️ Mitigation & Hardening
* Revoked all active sessions and tokens for the account immediately.
* Reduced session token lifetime and required step-up re-authentication for sensitive actions.
* Fully reimaged the endpoint — a quarantined file doesn't guarantee data taken before detection is undone.
* Reviewed every other "quarantined, closed" infostealer alert from the same week for the same gap.

## 📂 Repository Artifacts
* `queries.spl` — Splunk query surfacing one session ID active across multiple device fingerprints.

## 📝 Case Notes
"Quarantined" describes the malware, not what it already did before quarantine happened. This case
turned on treating an old, closed ticket as evidence instead of history.
