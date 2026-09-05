# QR-Code Phishing ("Quishing") — Awareness Note

Why it works: most email security tools scan links in text, not links hidden inside images. A QR
code carrying a malicious URL can pass through filters that would catch the same link written out.

What to watch for:
- Unexpected requests to "scan to verify" or "scan to re-authenticate"
- QR codes in emails claiming urgency (account lockout, MFA expiry)
- Sender domains that look almost right but not quite (one swapped character, added hyphen)

What to do:
- Don't scan work-related QR codes with a personal, unmanaged phone
- Report the email instead of scanning — IT can inspect the code safely in a sandbox
- If you already scanned and entered credentials: report it immediately, don't wait
