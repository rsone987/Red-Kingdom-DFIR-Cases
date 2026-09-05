# Case #15: One Key, Every Door — Fleet-Wide Lateral Movement

**Difficulty:** 🔴 Advanced &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~3 days

## 🚨 Scenario Overview
One compromised workstation turned into admin-level access on 40+ servers across three
departments within the same night — far faster than any credential-guessing or exploit chain should
allow.

## 🕵️ First Theory — A Domain Admin Account Was Stolen
Forty servers compromised in one night looked like a Domain Admin credential theft — the usual
suspect for that kind of speed and scale. Domain Admin logs came back completely clean. No
Domain Admin session touched any of these hosts.

## 🔦 The Detail That Redirected the Investigation
Every compromised host was accessed the same way: a **local Administrator** account, not a domain
account. Forty different servers, forty different local Administrator logins — using the exact same
password, on every single one.

```bash
$ pth-winexe -U Administrator%<hash> //10.10.20.15 cmd
# succeeds — no password required, only the NTLM hash
```

## 🔎 The Real Investigation
This is a **pass-the-hash** lateral movement chain, and it only works at this scale because of one
underlying fact: the local Administrator account had the **same password hash on every server in
the fleet** — a legacy imaging practice from when the servers were first provisioned, years earlier,
and never revisited since. Compromise one machine's local admin hash, and you've effectively
compromised all of them simultaneously — no domain account, no MFA, nothing else required.

```spl
index=win_logs EventCode=4624 LogonType=3 Account_Name="Administrator"
| stats dc(Computer) as hosts_touched by src_ip
| where hosts_touched > 5
```

## 🛠️ Mitigation & Hardening
* Deployed **Windows LAPS**, assigning a unique, randomly generated local Administrator password
  per machine, rotated automatically and stored securely in Active Directory.
* Reset the shared local Administrator password on every affected host immediately, breaking the
  lateral movement chain before further containment even began.
* Restricted local Administrator network logon rights via Group Policy, so the account can no longer
  be used for remote lateral movement at all, LAPS or not.

## 📂 Repository Artifacts
* `laps_deployment_checklist.md` — Standing checklist for rolling out and verifying LAPS coverage.
* `queries.spl` — Splunk query surfacing a single account authenticating across an unusual number of
  distinct hosts.

## 📝 Case Notes
One shared password, set once during initial imaging years ago, was the entire reason a single
workstation compromise became a fleet-wide incident in one night. The domain layer was never
touched — it didn't need to be. The weakest link was a convenience decision nobody thought to undo.
