# Case #10: The Impostor — A Process Hollowing Attack

**Difficulty:** 🔴 Advanced &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~5 days

## 🚨 Scenario Overview
A web server started generating encrypted outbound traffic to an unfamiliar host and spawning
short-lived child shells — but the process behind it all was `nginx`, running under its normal
systemd unit, at its normal PID, owned by its normal user. Every identity check said this was exactly
the process that was supposed to be there.

## 🕵️ First Theory — A Compromised Plugin
The obvious read: a vulnerable nginx module or a poisoned third-party plugin. I patched nginx to the
latest version and restarted the service. The alert went quiet for six hours — then came back,
unchanged, from the same "legitimate" process.

## 🔦 The Detail That Broke the Theory
A patch and a restart wiping the process and the traffic returning identically meant the malicious
code wasn't living in a config file or a plugin that patching would touch. It had to be living somewhere
a restart doesn't necessarily clean — inside the process's own memory, right where the real
executable image is supposed to be.

```bash
$ md5sum /usr/sbin/nginx
a1b2c3d4e5f6... /usr/sbin/nginx

$ cat /proc/$(pgrep nginx | head -1)/maps | grep 'r-xp' | head -1
55f2a1000000-55f2a1200000 r-xp 00000000 08:01 nginx

$ dd if=/proc/$(pgrep nginx | head -1)/mem bs=1 skip=$((0x55f2a1000000)) count=2097152 2>/dev/null | md5sum
9f8e7d6c5b4a... -
```

The hash of the code sitting in the running process's memory **did not match** the hash of the binary
on disk — for a process that had supposedly just been restarted from that exact binary.

## 🔎 The Real Investigation
This is **process hollowing**: the legitimate `nginx` process was started normally, then its in-memory
executable image was unmapped and replaced with malicious code while every external identifier —
name, PID, parent, owning user — stayed untouched. Every tool that checks "is this the right process
name at the right path" reports a clean result, because technically, it is — it's just not running what
that path actually contains anymore.

```bash
$ cat /proc/sys/kernel/yama/ptrace_scope
0
```

`ptrace_scope` was set to its most permissive value, allowing any process with the right privilege to
attach to and rewrite another process's memory — exactly the primitive this technique depends on.
Tracing back the injecting process led to the same web-app foothold from an earlier, smaller alert
that had been triaged as low-priority and never fully closed out.

## 🛠️ Mitigation & Hardening
* Restricted `ptrace_scope` to its most secure setting, blocking arbitrary cross-process memory access.
* Deployed a scheduled in-memory-vs-on-disk hash comparison for critical service binaries.
* Closed the loop on the earlier "low-priority" web-app alert that turned out to be the actual entry point.
* Added alerting on unexpected child processes spawned by service accounts that should never shell out.

## 📂 Repository Artifacts
* `memory_integrity_check.sh` — Compares a running process's in-memory code against its on-disk binary.
* `queries.spl` — Splunk query correlating "legitimate" service processes with anomalous child processes.

## 📝 Case Notes
Every identity check we normally trust — name, PID, path, owning user — passed. The only thing that
didn't match was the one thing nobody thinks to check: whether the code actually running is the code
that's actually on disk. An earlier "low-priority" alert sitting open for weeks was the real root cause,
not the technique itself.
