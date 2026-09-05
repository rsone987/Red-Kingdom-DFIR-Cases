# Case #14: The Unwatched Neighbor — A Mandatory Access Control Gap

**Difficulty:** 🔴 Advanced &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~4 days

## 🚨 Scenario Overview
A known, already-patched vulnerability in a logging utility got exploited anyway — weeks after the
patch had shipped, on a host where the patch was confirmed installed. The exploit shouldn't have
worked at all.

## 🕵️ First Theory — The Patch Didn't Actually Apply
Reasonable first move: assume the patch process failed silently, and the vulnerable code was still
present despite what the package manager reported.

```bash
$ dpkg -l | grep logging-utility
ii  logging-utility  2.3.4-patched  amd64
```

Patched version, correctly installed, confirmed. The exploit worked against code that genuinely
wasn't vulnerable anymore — which meant the exploit wasn't really the point of entry. It was a
stepping stone to something else.

## 🔦 The Detail That Redirected the Investigation
The "successful exploit" alert wasn't actually a full compromise — it was the attacker's process
crashing partway through, but not before it read a file it had no legitimate reason to touch:
`/etc/app-secrets/db_credentials.conf`, belonging to a completely unrelated service running on the
same host.

## 🔎 The Real Investigation
```bash
$ aa-status
apparmor module is loaded.
0 profiles are loaded.
0 profiles are in enforce mode.
0 profiles are in complain mode.
```

**Zero** AppArmor profiles active on the host. The logging utility process — even mid-exploit-attempt,
even crashing — ran with the same filesystem visibility as everything else on the box. There was no
boundary stopping it from reading a completely unrelated application's credential file, because
nothing had ever told the kernel that boundary should exist.

This is the same category of gap behind **Case #06**: a process compromise turning into a
much bigger blast radius than it should have, because nothing was actually isolating one service's
access from another's, beyond standard file permissions that a running process under the right user
can simply read past.

## 🛠️ Mitigation & Hardening
* Built and enforced AppArmor profiles for every service on the host, explicitly scoping each one to
  only the files and paths it actually needs.
* Rotated the exposed database credentials immediately.
* Standardized MAC profile creation as a required step in the service-deployment checklist, not an
  optional hardening extra.

## 📂 Repository Artifacts
* `apparmor_profile_template.txt` — Baseline AppArmor profile template used for new service rollouts.
* `queries.spl` — Splunk query flagging file access outside a process's expected working directory.

## 📝 Case Notes
Patching the vulnerability was necessary but not sufficient — the real lesson was that a fully patched,
correctly failing exploit attempt still managed real damage, because standard Unix permissions alone
never stop a process from reading whatever its user account can technically access. Least privilege
at the account level and mandatory access control at the kernel level are two different walls, and this
host only had one of them.

## 🔗 Related Cases
* [Case #06 — The Container That Wasn't Contained](../Case-06-Container-Escape/) — the same "one
  process, no real boundary" pattern, at the container layer instead of the host layer.
