# Case #02: The Ghost in the Query — An Insider Threat That Wasn't

**Difficulty:** 🟡 Intermediate &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~14 hours

## 🚨 Scenario Overview
02:47 AM. The Red Kingdom's SOC flagged over 340 `SELECT` statements against the production
customer database, `prod_customers` — fired in under ten minutes, from the account of a frontend
developer, jdoe_frontend, who had no business reason to touch that table.

```spl
index=db_logs sourcetype=mysql_audit user=jdoe_frontend
| stats count by query_type, db_name
| where db_name="prod_customers"
```

## 🕵️ First Theory — The Obvious Suspect
The account was real. The session was authenticated. No alarms, no failed logins — whoever this was
had valid credentials from the start. The easy read: **an insider**. I pulled jdoe_frontend's recent
activity, found a support ticket from three weeks earlier about a denied internal transfer request, and
started drafting the incident report as a malicious insider case.

I was one signature away from recommending termination.

## 🔦 The Detail That Broke the Theory
Before closing the file, I ran one more check — the kind of due-diligence step that's easy to skip when
you already think you know the answer.

```bash
$ badge-query --user jdoe_frontend --date 2026-09-03
No badge swipe recorded for jdoe_frontend on 2026-09-03.
```

He wasn't in the building. Not "worked remotely" — **not badged in at all**, and no VPN session tied
to his usual device either. Someone else was inside his account.

```bash
$ grep "jdoe_frontend" /var/log/vpn/connections.log | tail -3
Sep 03 02:41:07 vpn-gw1 openvpn[1122]: jdoe_frontend CONNECT src=185.220.101.47 (RO)
```

An IP the account had never connected from, ever. This wasn't an insider threat. It was a stolen
credential — and I'd almost put an innocent man's name on a termination memo because the evidence
looked convenient instead of complete.

## 🔎 The Real Question
Credential theft happens. It's almost routine. What *isn't* routine is how far it got in ten minutes.
A phished frontend developer's account should be able to do frontend-developer damage — not touch
a production customer table at all. So I asked the question that mattered:

```sql
SHOW GRANTS FOR 'jdoe_frontend'@'%';
-- GRANT ALL PRIVILEGES ON *.* TO 'jdoe_frontend'@'%'
```

Root, on every database in the company. Granted 18 months ago during a rushed deploy. Never
revisited. The stolen password wasn't really the attacker's weapon — **the permission was.**

## 🔦 The Bigger Reveal
Closing this as a one-account fix would have been the easy version of the ending. I audited every
account with a similarly broad grant instead of just this one:

```sql
SELECT grantee, privilege_type
FROM information_schema.user_privileges
WHERE privilege_type = 'ALL PRIVILEGES' AND grantee != "'root'@'localhost'";
```

Six other accounts came back with the same blanket grant — all issued around the same rushed
deployment window. This was never a single overprivileged developer. It was a deployment habit that
had been quietly handing out master keys for a year and a half.

## 🛠️ Mitigation & Hardening
* Revoked the blanket grant on jdoe_frontend and re-scoped it to the frontend schema only.
* Forced credential rotation and VPN re-enrollment for the affected account.
* Audited and re-scoped all six additional accounts found with the same excessive grant.
* Instituted a mandatory quarterly privilege review — no grant survives without a documented reason.

## 📂 Repository Artifacts
* `queries.spl` — Splunk query used to isolate the anomalous DB access pattern.
* `remediation.sql` — Grant audit and least-privilege remediation used across all seven accounts.

## 📝 Case Notes
The hardest part of this case wasn't finding the attacker — it was catching myself building a case
against the wrong person because the story fit too neatly. The badge log cost me thirty seconds and
saved a career.
