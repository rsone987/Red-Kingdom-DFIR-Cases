# Case #11: Five Minutes Alone — A Single-User Mode Breach

**Difficulty:** 🟡 Intermediate &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~2 days

## 🚨 Scenario Overview
The root password on a rack server in Data Center 1 changed with no ticket, no change request, and
no matching login event in `auth.log` anywhere near the timestamp.

## 🕵️ First Theory — A Leaked Credential
A password change with no corresponding login looked like someone had direct database or config
access to the shadow file remotely — I focused the first hours on remote access paths: VPN, any
config management tool that could push a password change.

## 🔦 The Detail That Redirected It
Every remote path came back clean. No VPN session, no config management run, nothing in any
remote audit trail at all. If it wasn't remote, the only thing left was standing in front of the machine.

```bash
$ badge-query --location "DC-1-Rack-C" --date 2026-09-05 --start 01:00 --end 02:00
01:14:02 - Badge ID: OPS-4471 - Access Granted - Rack Room C
```

A valid badge, an authorized technician — but authorized to be there is not the same as authorized to
do what came next.

## 🔎 The Real Investigation
`auth.log` shows nothing because the technique used never touches it: reboot the machine, interrupt
the bootloader, and pass the kernel a single boot parameter.

```
GRUB edit mode: linux /vmlinuz ... ro quiet splash init=/bin/bash
```

Booting straight to `/bin/bash` as PID 1 drops you into a root shell with **no login, no auth check, and
no log entry** — because the login process that would normally write one never runs. From there,
`passwd root` and a clean reboot, and the only trace left behind is the new password hash itself.

## 🛠️ Mitigation & Hardening
* Set a GRUB bootloader password, separate from the root account password, required to edit boot
  parameters at all.
* Enabled full-disk encryption (LUKS) — an encrypted root partition can't be mounted and rewritten
  from an alternate boot path without the unlock key.
* Restricted rack room access to a smaller, more tightly logged set of personnel, and required
  two-person presence for any unscheduled maintenance.

## 📂 Repository Artifacts
* `grub_hardening.sh` — Sets a GRUB bootloader password and disables unauthenticated edit mode.
* `queries.spl` — Splunk query flagging unscheduled reboots with no preceding maintenance ticket.

## 📝 Case Notes
If someone can stand in front of a server, digital hardening alone doesn't hold — the operating system
was never in a position to log an event that happened before it finished booting. Physical access is a
root shell waiting to happen, unless the boot process itself is locked down.
