# Case #06: The Container That Wasn't Contained

**Difficulty:** 🔴 Advanced &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~3 days

## 🚨 Scenario Overview
Root-level file changes started appearing on a production host — new binaries, modified system
files — with no matching login session, no SSH activity, nothing in the usual places.

## 🕵️ First Theory — The Host Itself Was Compromised
Since the changes were host-level, I focused the entire first day on the host: checked SSH logs,
rotated credentials, reviewed sudo history. All clean. Whatever this was, it wasn't logging in the
normal way.

## 🔦 The Detail That Redirected the Investigation
Process ancestry told a different story. The process making root-level changes wasn't a normal host
process at all — its parent PID traced into a **container's PID namespace**.

```bash
$ ps -eo pid,ppid,cmd | grep <suspicious_pid>
<pid>  <container_init_pid>  /bin/sh -c "..."
```

A containerized process shouldn't be able to touch the host filesystem at all. Something had broken
the isolation that's supposed to make that impossible.

## 🔎 The Real Investigation
```bash
$ docker inspect <container_id> --format '{{ .HostConfig.Binds }}'
[/var/run/docker.sock:/var/run/docker.sock]

$ docker inspect <container_id> --format '{{ .HostConfig.Privileged }}'
false

$ docker inspect <container_id> --format '{{ .Config.User }}'
(empty — running as root)
```

Two leftovers from a debugging session, months old and never cleaned up: the container ran as
**root**, and it had the **Docker socket mounted inside it**. A web-app CVE gave the attacker code
execution inside the container; from there, the mounted socket let them talk directly to the Docker
daemon and spin up a brand-new **privileged** container with the host filesystem mounted straight
into it — full host access, no exploit chain required beyond that one mount.

## 🛠️ Mitigation & Hardening
* Removed the Docker socket mount from every application container fleet-wide.
* Enforced non-root users inside every container image.
* Applied seccomp and AppArmor profiles to restrict container syscall access.
* Restricted Docker API access to a small, audited set of orchestration hosts only.

## 📂 Repository Artifacts
* `docker_inspect_audit.sh` — Fleet-wide scan for privileged containers and socket mounts.
* `queries.spl` — Splunk query correlating container escapes with host-level file changes.

## 📝 Case Notes
Nothing here was a zero-day. It was a debugging convenience someone forgot to remove — the socket
mount alone was the entire attack surface. Isolation only works if nobody quietly punches a hole in it.
