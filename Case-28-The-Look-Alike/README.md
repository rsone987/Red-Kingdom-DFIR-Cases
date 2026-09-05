# Case #28: The Look-Alike — A Phishing Campaign Hiding in Plain Sight

**Difficulty:** 🔴 Advanced &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~3 days

## 🚨 Scenario Overview
A handful of employees reported a strange but oddly convincing email: an "MFA re-verification
required" notice asking them to scan a QR code with their phone. The email security gateway had let
every one of them through without a single flag.

## 🕵️ First Theory — A False Alarm
The email contained no clickable link at all — nothing for the URL scanner to catch, no attachment,
no obvious spoofed sender domain in the visible display name. First pass through the mail security
tooling came back completely clean, and the initial read was a slightly odd but harmless internal IT
notice.

## 🔦 The Detail That Broke It
```spl
index=mail_audit_logs sender_domain!="company.com"
| stats count by sender_domain, subject
| where match(subject, "(?i)mfa.*verif")
```

The sender domain wasn't `company.com` — it was a close visual look-alike, one character
substituted, registered nine days earlier. The email's URL scanner had nothing to flag because there
was no URL in the message text at all: the malicious link was embedded entirely inside the **QR code
image**, invisible to any tool that only inspects text and links.

## 🔎 The Real Investigation
Scanning the QR code in a sandboxed environment led to a convincing clone of the company's SSO
login page on the look-alike domain. Because employees scanned it with personal phones — outside
any corporate device management or browser protection — the credential harvest happened entirely
off the monitored network, with the first visibility into it coming only from users reporting the email
itself, not from any automated detection.

```bash
$ whois lookalike-domain.com
Creation Date: 2026-08-27T00:00:00Z   # 9 days before the campaign
Registrar: <privacy-protected registrar>
```

At least two employees confirmed scanning the code and entering credentials before the pattern was
caught and the domain reported for takedown.

## 🛠️ Mitigation & Hardening
* Forced password resets and session revocation for every employee who confirmed interacting with
  the code.
* Reported the look-alike domain for takedown and blocked it at the DNS/proxy layer.
* Extended email security scanning to decode and inspect QR code images for embedded URLs, not
  just text-based links.
* Ran a targeted awareness note specifically on QR-code phishing ("quishing") — a technique most
  existing training material never covers.

## 📂 Repository Artifacts
* `queries.spl` — Splunk query surfacing look-alike sender domains with MFA-themed subject lines.
* `qr_phishing_awareness_note.md` — Short awareness note on QR-code phishing for employee training.

## 📝 Case Notes
Every layer of automated defense was looking for the wrong shape of threat: a link in text. The
attacker simply moved the link somewhere none of those tools were built to look — a lesson in
checking what a control actually inspects, not just whether a control exists.
