# Case #20: The Mailbox Rule

**Difficulty:** 🟡 Intermediate &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~1 day

## 🚨 Scenario Overview
Several colleagues reported receiving unusual messages that appeared to come directly from a
coworker's real email account — not a spoofed look-alike domain, the actual account.

## 🕵️ First Theory — Header Spoofing
The first, most common explanation: display-name or header spoofing, no real compromise involved.
Standard response: warn recipients, no action needed on the source account.

## 🔦 The Detail That Broke It
The messages were sitting in the coworker's own **Sent Items** folder. Spoofing doesn't do that —
only an actual, authenticated send from the real account leaves a copy there.

```spl
index=mail_audit_logs user=coworker@company.com action="New-InboxRule"
| table _time, rule_name, forward_to, src_ip
```

## 🔎 The Real Investigation
A hidden inbox rule had been created days earlier, silently forwarding every incoming message
containing the word "invoice" to an external address — created from a sign-in session in a country
the employee had never traveled to. A reused, non-MFA-protected password had let the attacker in
directly; the rule and the outbound messages were reconnaissance for a follow-up invoice-fraud
attempt against finance contacts.

## 🛠️ Mitigation & Hardening
* Removed the malicious forwarding rule and reset the account's credentials.
* Enforced MFA on the account (and audited for any other accounts still missing it).
* Revoked all active sessions tied to the compromised login.
* Reviewed Sent Items and forwarded messages to notify affected external contacts before any
  invoice fraud could be attempted against them.

## 📂 Repository Artifacts
* `queries.spl` — Splunk query surfacing new mailbox forwarding rules pointing to external domains.

## 📝 Case Notes
Everyone's first instinct was "spoofing" because that's the more common, less alarming explanation.
One glance at Sent Items instead of just the inbox is what actually settled it.
