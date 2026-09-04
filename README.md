# 🛡️ The Red Kingdom | DFIR & Threat Hunting Case Files

A self-directed, scenario-based DFIR case study series — realistic investigations built to practice
and demonstrate incident response methodology end-to-end: detection, root-cause analysis, and
remediation, written up the way a working SOC/DFIR analyst would document a real incident.

Each case is set against **The Red Kingdom**, a fictional enterprise environment, with **Rami** as
the investigator. The scenarios are constructed, but the investigative methodology, the tools, and the
detection logic are the same ones used throughout this author's real hands-on lab work (see the
[Sentinel SOC](https://github.com/rsone987) project). Cases are ordered by difficulty, not by date —
each one includes the false leads and dead ends that came before the actual answer, not just the
clean resolution.

## 🏢 Simulated Environment Profile
* **Enterprise:** The Red Kingdom (Global Infrastructure & Hybrid Workforce) — fictional
* **SIEM & Analytics:** Splunk Enterprise
* **UEBA Telemetry:** DTEX InTERCEPT
* **Authentication & Access:** Physical Badge Readers, Enterprise VPN, SSH Keys

---

## 📚 Investigation Archives

| Case ID | Incident Title | Difficulty | Severity | Primary Tools | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Case #01** | [The Midnight Phantom: SSH Brute-Force Triage](./Case-01-SSH-BruteForce/) | 🟢 Beginner | 🟠 High | Splunk, DTEX, Linux CLI | 🟢 Resolved |
| **Case #02** | [The Ghost in the Query: An Insider Threat That Wasn't](./Case-02-Ghost-in-the-Query/) | 🟡 Intermediate | 🔴 Critical | Splunk, DTEX, VPN Logs, Badge Readers | 🟢 Resolved |
| **Case #03** | [The Ghost in the Machine: The Bootkit That Shouldn't Exist](./Case-03-Ghost-in-the-Machine/) | 🔴 Advanced | 🟠 High | Splunk, Badge Readers, HR Systems, Firmware CLI | 🟢 Resolved |
| **Case #04** | [The Forgotten Door: A Shadow IT Server](./Case-04-Shadow-IT/) | 🟡 Intermediate | 🟠 High | Nmap, Splunk, Asset Inventory | 🟢 Resolved |
| **Case #05** | [Backups Under Siege: The Restore That Failed](./Case-05-Backup-Siege/) | 🔴 Advanced | 🔴 Critical | Splunk, Backup Audit Logs, Restic | 🟢 Resolved |
| **Case #06** | [The Container That Wasn't Contained](./Case-06-Container-Escape/) | 🔴 Advanced | 🔴 Critical | Docker CLI, Splunk, Auditd | 🟢 Resolved |
| **Case #07** | [The Blind Spot: What eBPF Finally Showed Us](./Case-07-The-Blind-Spot/) | 🔴 Advanced | 🟠 High | eBPF/bpftrace, Splunk, Netflow | 🟢 Resolved |
| **Case #08** | [Ghost Process: Hunting a Rootkit That Wasn't There](./Case-08-Ghost-Process/) | ⚫ Expert | 🔴 Critical | Linux Kernel Forensics, Live-Boot Analysis | 🟢 Resolved |
| **Case #09** | [The Golden Ticket: A Domain Admin Who Was Never There](./Case-09-Golden-Ticket/) | ⚫ Expert | 🔴 Critical | Splunk, Windows Event Logs, Active Directory | 🟢 Resolved |

---

## 👤 Investigator
**Rami** — Aspiring SOC/DFIR Analyst. This series is a self-directed methodology exercise; see the
[Sentinel SOC](https://github.com/rsone987) repository for the hands-on lab this investigative
approach is drawn from.
