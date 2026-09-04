# Case #07: The Blind Spot — What eBPF Finally Showed Us

**Difficulty:** 🔴 Advanced &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~16 days

## 🚨 Scenario Overview
Network flow logs kept showing short bursts of outbound traffic to an unfamiliar external address —
a few times a day, gone in under a second. Every time we checked process and connection logs on
the host at that exact timestamp, there was nothing there.

## 🕵️ First Theory — Monitoring Noise
Two weeks of this, with `ps`, `netstat`, and our standard polling-based process monitor all coming up
empty every single time, and the pattern was written off as a flow-log artifact — probably NAT
misattribution, or a monitoring bug. It kept happening anyway.

## 🔦 The Detail That Changed the Approach
Every polling-based tool checks the system every few seconds. If something exists for **less than
that interval**, polling will never catch it — it isn't broken, it's just too slow for what it's looking for.

## 🔎 The Real Investigation
Instead of asking the OS what's running (which a fast-lived process can simply outrun), we watched
the kernel directly, in real time, with eBPF:

```bash
$ sudo bpftrace -e '
  tracepoint:syscalls:sys_enter_execve { printf("%s %s\n", comm, str(args->filename)); }
  tracepoint:syscalls:sys_enter_connect { printf("%s -> connect()\n", comm); }
'
```

Within an hour: a process spawned, opened a connection, and self-terminated in **under 40
milliseconds** — well under any polling tool's sampling interval, every single time it fired.

```
14:02:11.884 payload_stub -> execve()
14:02:11.901 payload_stub -> connect()
14:02:11.921 [process exited]
```

## 🔦 Root Cause
This wasn't stealthy code or an unknown exploit — it was a well-known evasion technique executed
well: memory-resident payload, extremely short process lifetime, timed specifically to slip between
the sampling intervals of every traditional, polling-based monitoring tool in the stack.

## 🛠️ Mitigation & Hardening
* Deployed a continuous, kernel-level monitoring stack (Tetragon) instead of relying on interval-based
  polling tools.
* Built alerting on the underlying syscall pattern itself (execve immediately followed by connect,
  short-lived), not just on "known-bad" process names.
* Documented the finding for the wider team: **if a detection strategy depends on being fast enough
  to catch something, assume the next attacker will simply be faster.**

## 📂 Repository Artifacts
* `trace_short_lived_procs.bt` — bpftrace script used to catch the sub-second execution pattern.
* `queries.spl` — Splunk correlation between network flow bursts and the process-monitoring gap.

## 📝 Case Notes
The two weeks lost here weren't a tooling failure — they were a category error. We kept asking a
polling tool to catch something built specifically to be faster than polling. The fix wasn't a better
poll interval. It was watching continuously instead of asking periodically.
