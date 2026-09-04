# Case #08: Ghost Process — Hunting a Rootkit That Wasn't There

**Difficulty:** ⚫ Expert &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~9 days

## 🚨 Scenario Overview
Network monitoring kept flagging outbound traffic from a host to a known-bad IP range. Every time we
checked the host itself — `ps aux`, `netstat -tulpn`, the AV agent — it came back completely clean.
Not suspicious-clean. Perfectly, suspiciously clean.

## 🕵️ First Theory — Misattribution
With nothing showing up on the host across three separate checks, the leading theory was NAT
misattribution — the traffic belonged to a different machine sharing the gateway. Reasonable. Also
wrong.

## 🔦 The Detail That Broke It
`ps` and `netstat` don't look at raw system state directly — they ask the kernel, through system
calls, and trust the answer. If something can intercept those calls and edit the answer before it
reaches the tool, the tool will report a lie with total confidence. So we stopped asking the kernel and
looked at what it was managing directly.

```bash
$ ls /proc | grep -E '^[0-9]+$' | wc -l
142

$ ps aux | wc -l
131
```

Eleven process directories existed in `/proc` that `ps` never showed. That gap doesn't happen by
accident.

## 🔎 The Real Investigation
```bash
$ cat /proc/<hidden_pid>/net/tcp
# raw socket table shows an active connection ps/netstat never reported

$ lsmod | diff - known_clean_modules.txt
> nvme_helper_x86    16384  0
```

An unsigned kernel module, named to blend in, present on this host and nowhere else in the fleet. To
confirm without trusting the potentially-compromised running kernel at all, we booted the drive from
an external clean live-USB image and inspected it from outside the infected OS:

```bash
$ mount /dev/sdb1 /mnt/forensic
$ grep -r "nvme_helper_x86" /mnt/forensic/lib/modules/
```

Confirmed: a Loadable Kernel Module rootkit, hooking the syscalls that `ps` and `netstat` rely on to
hide its own process and network connection from every standard tool on the box.

## 🛠️ Mitigation & Hardening
* Rebuilt the host from a known-clean image — a rootkit at this level isn't something you clean, only
  something you replace.
* Enabled kernel **module signing** fleet-wide so only signed, trusted modules can load.
* Disabled unnecessary module loading entirely on hosts that don't need it.
* Added a standing procedure: any host with unexplained network activity and clean userspace tools
  gets checked from an external boot image before being trusted again.

## 📂 Repository Artifacts
* `module_integrity_check.sh` — Compares loaded kernel modules against a known-clean baseline.
* `live_boot_forensic_checklist.md` — Steps for inspecting a host without trusting its own kernel.

## 📝 Case Notes
This one earns its difficulty rating honestly: the tools you'd normally trust to tell you the truth were
the ones lying. The only way through was to stop asking the compromised kernel questions and go
look at the raw state ourselves.
