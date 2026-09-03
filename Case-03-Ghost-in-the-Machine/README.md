# Case #03: The Ghost in the Machine — The Bootkit That Shouldn't Exist

**Difficulty:** 🔴 Advanced &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~6 days

## 🚨 Scenario Overview
A rack server in Data Center 2, `srv-datacenter-14`, had been rebooting at random for eleven days.
No malware alerts. No AV hits. Every log came back clean. This one took a week to close, and for the
first four days, I was chasing the wrong thing entirely.

## 🕵️ First Theory — Hardware Fault
Random reboots with zero software evidence usually mean one thing: failing hardware. I ordered a
memory diagnostic and a PSU swap. Both came back clean. Two days spent, no answer, and the
reboots kept happening — always overnight, never during business hours.

## 🔦 The Pattern I Almost Missed
On day four, I stopped looking at *what* was happening and started looking at *when*. Every reboot
clustered around the same two-hour window, always after 2 AM. That's not a hardware failure pattern
— hardware doesn't check a clock. That's a **behavior**.

```spl
index=server_logs host=srv-datacenter-14 sourcetype=syslog
| eval hour=strftime(_time, "%H")
| stats count by hour
| sort - count
```

## 🕵️ Second Theory — Legitimate Maintenance
If it wasn't hardware and it wasn't malware, the next explanation was the boring one: scheduled
maintenance nobody had logged properly. I pulled the badge log for the rack room.

```bash
$ badge-query --location "DC-Rack-Room-B" --date 2026-09-03 --start 02:00 --end 04:00
02:58:13 - Badge ID: MTX-2291 (Maintenance Tech) - Access Granted - Rack Room B
```

A valid badge. A real technician on file. I almost closed the case right there as "undocumented
maintenance, resolved via policy reminder" — the kind of ending nobody remembers.

## 🔦 The Detail That Reopened Everything
Almost. I cross-checked the technician's shift schedule out of habit, not suspicion.

```bash
$ hr-schedule --employee "MTX-2291" --date 2026-09-03
Employee: M. Kessler — Status: APPROVED LEAVE (Sep 01 - Sep 07)
```

Badge MTX-2291 opened a locked server room at 2:58 AM, on a night its registered owner was
**on approved leave, out of the country**. That badge was cloned or stolen — and whoever was
holding it had physical, hands-on-hardware access to a production server, repeatedly, for over a week.

## 🔎 The Real Investigation
Physical access with no software trace meant one thing: whatever was happening lived **below** the
operating system, in a place none of my log sources could see. I checked the firmware directly.

```bash
$ mokutil --sb-state
SecureBoot disabled

$ efibootmgr -v
BootCurrent: 0004
Boot0004* USB HDD    PciRoot(0x0)/Pci(0x14,0x0)/USB(2,0) ...
```

Secure Boot off. USB boot enabled. No BIOS administrator password. Every night, someone had been
walking in with a stolen badge and a USB drive, letting a **bootkit** re-establish itself below the OS —
completely invisible to every AV and EDR agent running on top of it. The "random reboots" weren't
random at all. They were the bootkit reasserting control after each patch cycle tried to clean the OS
layer it never actually lived in.

## 🛠️ Mitigation & Hardening
* Wiped and reflashed the server's firmware from a verified clean image.
* Enabled Secure Boot to enforce signed, trusted boot code only, fleet-wide.
* Disabled boot from all external media (USB/CD) across every rack in Data Center 2.
* Set BIOS/UEFI administrator passwords on every host in the data center.
* Revoked and reissued all physical badge credentials; audited the badge system for cloning
  vulnerabilities.

## 📂 Repository Artifacts
* `queries.spl` — Splunk query used to surface the time-of-day reboot pattern.
* `firmware_check.sh` — Commands used to audit Secure Boot state and boot order.
* `hardening_checklist.md` — Standard BIOS/UEFI hardening checklist applied fleet-wide.

## 📝 Case Notes
Two false closes on this one — hardware, then "legitimate maintenance" — before the real answer.
The lesson wasn't technical. It was procedural: a valid badge number is not the same thing as a valid
reason for someone to be standing in that room. I check the schedule now, every time, no exceptions.
