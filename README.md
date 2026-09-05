# 🛡️ The Red Kingdom | DFIR & Threat Hunting Case Files

A self-directed, scenario-based DFIR case study series — realistic investigations built to practice
and demonstrate incident response methodology end-to-end: detection, root-cause analysis, and
remediation, written up the way a working SOC/DFIR analyst would document a real incident.

Each case is set against **The Red Kingdom**, a fictional enterprise environment, with **Rami** as
the investigator. The scenarios are constructed, but the investigative methodology, the tools, and the
detection logic are the same ones used throughout this author's real hands-on lab work (see the
[Sentinel SOC](https://github.com/rsone987) project). Every case includes the false leads and dead
ends that came before the actual answer, not just the clean resolution.

## 🏢 Simulated Environment Profile
* **Enterprise:** The Red Kingdom (Global Infrastructure & Hybrid Workforce) — fictional
* **SIEM & Analytics:** Splunk Enterprise
* **UEBA Telemetry:** DTEX InTERCEPT
* **Authentication & Access:** Physical Badge Readers, Enterprise VPN, SSH Keys

---

## 📊 Series Overview

**23 cases resolved** — 🟢 1 Beginner · 🟡 5 Intermediate · 🔴 14 Advanced · ⚫ 3 Expert

---

## 📚 Investigation Archives

### 🟢 Beginner
| Case | Incident Title | Primary Tools |
| :--- | :--- | :--- |
| **#01** | [The Midnight Phantom: SSH Brute-Force Triage](./Case-01-SSH-BruteForce/) | Splunk, DTEX, Linux CLI |

### 🟡 Intermediate
| Case | Incident Title | Primary Tools |
| :--- | :--- | :--- |
| **#02** | [The Ghost in the Query: An Insider Threat That Wasn't](./Case-02-Ghost-in-the-Query/) | Splunk, DTEX, VPN Logs, Badge Readers |
| **#04** | [The Forgotten Door: A Shadow IT Server](./Case-04-Shadow-IT/) | Nmap, Splunk, Asset Inventory |
| **#11** | [Five Minutes Alone: A Single-User Mode Breach](./Case-11-Single-User-Mode/) | Badge Readers, GRUB/LUKS, Linux CLI |
| **#12** | [Under Fire: A DDoS at the Edge](./Case-12-DDoS-Under-Fire/) | Splunk, Network/Firewall Logs |
| **#16** | [The Stolen Session](./Case-16-The-Stolen-Session/) | Splunk, IdP Logs, Endpoint Telemetry |
| **#20** | [The Mailbox Rule](./Case-20-The-Mailbox-Rule/) | Splunk, Mail Audit Logs |

### 🔴 Advanced
| Case | Incident Title | Primary Tools |
| :--- | :--- | :--- |
| **#03** | [The Ghost in the Machine: The Bootkit That Shouldn't Exist](./Case-03-Ghost-in-the-Machine/) | Splunk, Badge Readers, HR Systems, Firmware CLI |
| **#05** | [Backups Under Siege: The Restore That Failed](./Case-05-Backup-Siege/) | Splunk, Backup Audit Logs, Restic |
| **#06** | [The Container That Wasn't Contained](./Case-06-Container-Escape/) | Docker CLI, Splunk, Auditd |
| **#07** | [The Blind Spot: What eBPF Finally Showed Us](./Case-07-The-Blind-Spot/) | eBPF/bpftrace, Splunk, Netflow |
| **#10** | [The Impostor: A Process Hollowing Attack](./Case-10-Process-Hollowing/) | Linux Memory Forensics, Splunk, Auditd |
| **#13** | [The Secret in the History](./Case-13-Secret-in-the-History/) | Git, Cloud Audit Logs |
| **#14** | [The Unwatched Neighbor: A MAC Gap](./Case-14-The-Unwatched-Neighbor/) | AppArmor, Auditd, Splunk |
| **#15** | [One Key, Every Door: Fleet-Wide Lateral Movement](./Case-15-One-Key-Every-Door/) | Windows LAPS, Windows Event Logs |
| **#17** | [The PowerShell Breadcrumb](./Case-17-The-PowerShell-Breadcrumb/) | Sysmon, Splunk |
| **#18** | [The Quiet Preparation](./Case-18-The-Quiet-Preparation/) | Splunk, Windows Event Logs |
| **#19** | [The Database Nobody Touched](./Case-19-The-Database-Nobody-Touched/) | WAF Logs, DB Audit Logs, Splunk |
| **#22** | [The DNS That Spoke Too Much](./Case-22-The-DNS-That-Spoke-Too-Much/) | DNS Logs, Splunk |
| **#23** | [The Insider Who Wasn't](./Case-23-The-Insider-Who-Wasnt/) | Splunk, Badge Readers, Endpoint Forensics |

### ⚫ Expert
| Case | Incident Title | Primary Tools |
| :--- | :--- | :--- |
| **#08** | [Ghost Process: Hunting a Rootkit That Wasn't There](./Case-08-Ghost-Process/) | Linux Kernel Forensics, Live-Boot Analysis |
| **#09** | [The Golden Ticket: A Domain Admin Who Was Never There](./Case-09-Golden-Ticket/) | Splunk, Windows Event Logs, Active Directory |
| **#21** | [The Trusted Path: A Multi-Hop Lateral Movement Chain](./Case-21-The-Trusted-Path/) | Windows Event Logs, WinRM/SMB Telemetry |

---

## 🧭 How This Series Grows

This isn't a fixed set — it's an ongoing case log. New cases get added whenever a new scenario,
technique, or lesson comes up worth documenting the same way: a realistic incident, a first theory
that turns out wrong, the evidence that corrects it, and a clear root cause with real, runnable
artifacts. No fixed schedule — cases are added as they're built.

---

## 👤 Investigator
**Rami** — Aspiring SOC/DFIR Analyst. This series is a self-directed methodology exercise; see the
[Sentinel SOC](https://github.com/rsone987) repository for the hands-on lab this investigative
approach is drawn from.
