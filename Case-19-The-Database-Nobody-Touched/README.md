# Case #19: The Database Nobody Touched

**Difficulty:** 🔴 Advanced &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~3 days

## 🚨 Scenario Overview
A production database started returning an unusual volume of records — but the database's own
access logs showed nothing abnormal: no new logins, no unfamiliar accounts, no failed auth attempts.

## 🕵️ First Theory — A Heavy Reporting Job
Query volume spikes are usually a scheduled report running long. The first check compared the
timing against known reporting jobs — no match, and the spike kept recurring at irregular hours no
report was ever scheduled for.

## 🔦 The Detail That Broke It
The database wasn't lying about being clean — it genuinely never saw anything wrong, because
**every query came from the application's own legitimate service account.** The problem wasn't at
the database layer at all.

```
WAF log: 03:14:02 — param "search" — payload: ' UNION SELECT username,password FROM users--
```

## 🔎 The Real Investigation
An unsanitized search parameter in the web application was vulnerable to SQL injection. The attacker
never touched the database directly — they issued malicious input to the web app, and the app's own,
fully-authorized database credentials executed the query on their behalf. From the database's point
of view, this was just the application doing what it always does.

```spl
index=waf_logs status=200 uri="/search"
| regex query_params="(?i)union\s+select|--|;\s*drop"
| join type=inner _time
    [ search index=db_audit_logs user="svc_webapp" | stats count by _time ]
```

## 🛠️ Mitigation & Hardening
* Patched the injection point with parameterized queries across the affected endpoint and audited
  similar input paths.
* Deployed a WAF rule specifically for the injection payload pattern observed.
* Re-scoped the application's database account to read-only access on the specific tables it
  legitimately needs — nothing broader.
* Added query-volume-per-application-identity as a standing anomaly baseline.

## 📂 Repository Artifacts
* `queries.spl` — Splunk query correlating WAF-flagged requests with database query spikes from the
  app's service account.

## 📝 Case Notes
A clean database audit log doesn't mean nothing happened — it can mean the attacker never needed
to be an unauthorized user, because the authorized application did the asking for them.
