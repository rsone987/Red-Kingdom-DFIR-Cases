# Case #13: The Secret in the History

**Difficulty:** 🔴 Advanced &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~3 days

## 🚨 Scenario Overview
An AWS-style API key started making calls from an IP address that had never touched our
infrastructure before. The key was valid, active, and — as far as anyone currently on the team knew —
had never been shared outside the company.

## 🕵️ First Theory — A Phished Developer
The obvious read: whoever holds that key got phished, or had a laptop compromised. I started a
standard credential-compromise response: revoke, rotate, review the developer's recent activity for
anything unusual.

## 🔦 The Detail That Broke the Theory
The developer's own activity was clean — no phishing email, no unusual login, no malware on their
machine. But the key itself had a clue in it nobody had looked at: **when it was first created**.

```bash
$ aws iam get-access-key-last-used --access-key-id AKIA...
CreateDate: 2024-11-03
```

Nearly two years old. The developer confirmed they'd rotated their working credentials multiple times
since then. This wasn't today's key being stolen today — it was an old key, still valid, that shouldn't
have existed anymore at all.

## 🔎 The Real Investigation
```bash
$ git log --all --full-history -p -- config/settings.yml | grep -i "AKIA"
commit 8f3a1c2 (2024-11-03)
+  aws_access_key: "AKIA...[REDACTED]"
```

The key had been committed directly into a YAML config file in a private repository over a year and a
half earlier, then "removed" in a later commit — which doesn't actually delete it. Git history keeps
every version forever unless someone specifically rewrites it. The key had been sitting, fully valid,
inside the repository's history the entire time, readable by anyone with clone access.

## 🛠️ Mitigation & Hardening
* Revoked the exposed key and rotated every credential that had ever appeared in repository history.
* Purged the secret from Git history using `git filter-repo`, and force-pushed the cleaned history.
* Migrated all secrets to a dedicated secrets manager (HashiCorp Vault) — nothing sensitive lives in a
  YAML file or a commit again.
* Added a pre-commit secret-scanning hook to catch this class of mistake before it ever reaches a
  commit.

## 📂 Repository Artifacts
* `secret_scan.sh` — Pre-commit hook script that blocks commits containing likely credential patterns.
* `queries.spl` — Splunk query correlating API activity from credentials older than the rotation policy.

## 📝 Case Notes
"We deleted that commit" is a comforting sentence and a technically false one. A secret that ever
touched version control has to be treated as burned the moment it's committed — deleting the file
later doesn't undo the history that still contains it.
