# Case #30 — The Archive That Wouldn't Open

**Difficulty:** Advanced
**Category:** Email Security / Perimeter Defense / Threat Intelligence
**Tools referenced:** NGFW Deep Packet Inspection, Secure Email Gateway, Splunk Enterprise, Threat Intel Feed

---

## The Callout

11:47 PM. A Tier-2 escalation landed from the mail gateway team: an inbound message to the procurement mailbox had been quarantined twice — and re-sent from a different external address within nine minutes. Someone was persistent. That alone was worth a look.

## The Evidence

Started at the mail gateway logs.

```
timestamp=23:38:04 action=DELIVERED sender=proc-support@[redacted-vendor].com
recipient=purchasing@redkingdom.local attachment=quarterly_statement.7z
sha256=... engine_result=CLEAN (extension not in blocklist)
```

Clean. No flags. The gateway's extension filter didn't even blink — `.7z` isn't on anyone's blocklist the way `.exe` or `.js` is. That's exactly the problem.

Pulled the firewall's deep packet inspection logs for the same window, since a mail gateway clearing something on extension alone was never going to be the end of the story.

```
splunk> index=firewall sourcetype=ngfw_dpi dest=10.20.10.50
| search file_type="7z" OR file_type="encrypted_archive"
| table _time, src_ip, dest_ip, verdict, threat_name
```

```
_time                src_ip           dest_ip        verdict     threat_name
23:38:06              203.0.113.x      10.20.10.50    ALLOWED     -
23:41:52              203.0.113.x      10.20.10.50    BLOCKED     Gen:Variant.Archive.Nested
```

Two attempts. The first slipped through the mail gateway clean and only got caught once it hit the perimeter firewall's DPI engine — which doesn't care what extension a file has, only what's actually inside it. The second attempt, from a different sending address but structurally near-identical, got blocked outright.

## The First Theory — And Why It Was Wrong

First read: single opportunistic phishing attempt, automated, low sophistication, close it out before midnight and forget by morning.

Then a closer look at the archive itself. It wasn't just password-protected — it was a **nested** archive: a `.7z` containing another encrypted container, a deliberate technique to defeat sandboxes that only unpack one layer deep before giving up. Not opportunistic. Someone who's tested this delivery method against detection tooling before sending it.

## The Twist

Checked how many other organizations had reported similar nested-archive deliveries against the same threat signature in the past 30 days across the threat-intel feed. Fourteen. Same nesting structure, same rough timing pattern, different senders each time — a campaign, not a one-off.

## The Resolution

- Blocked the sending infrastructure at the perimeter
- Pushed a mail-gateway rule to strip *any* password-protected or nested archive regardless of extension, pending manual sandbox detonation
- Notified procurement directly — not just "don't open," but *why*, with the actual subject line so they'd recognize the pattern if it came back reworded

## The Lesson

Extension-based filtering answers "what kind of file is this?" Deep packet inspection answers "what does this file actually do?" Those are different questions, and only one of them catches a `.7z` built specifically to look boring enough to get through.

If your perimeter's first line of defense stops at the file extension, you're filtering the wrapping paper and trusting whatever's inside it.
