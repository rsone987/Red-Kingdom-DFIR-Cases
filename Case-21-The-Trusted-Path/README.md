# Case #21: The Trusted Path — A Multi-Hop Lateral Movement Chain

**Difficulty:** ⚫ Expert &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~4 days

## 🚨 Scenario Overview
A single compromised workstation was flagged by EDR and quarantined the same day. Standard
procedure: reimage, close the ticket. A week later, unrelated alerts started firing on a server that had
no obvious connection to that workstation at all.

## 🕵️ First Theory — Two Unrelated Incidents
Nothing on the surface linked them — different hosts, different alert types, a week apart. The first
read was two separate, coincidental issues.

## 🔦 The Detail That Broke It
Looking at authentication events in isolation on each host showed nothing unusual — each single
login looked completely legitimate. Only building a **chain across hosts** revealed the pattern:

```spl
index=win_logs EventCode=4624 LogonType=3
| stats values(dest_host) as next_hop by src_host, Account_Name, _time
| sort _time
```

The same admin account authenticated from the compromised workstation to a jump server via
WinRM, then from that jump server to a file share one hop away from a Domain Controller — all within
nine minutes of the original workstation compromise, a full week before anyone noticed.

## 🔎 The Real Investigation
The account belonged to an IT support technician who had legitimately remoted into that workstation
for an unrelated help-desk ticket the same day it was compromised. Their credentials were captured
in that moment and reused immediately for lateral movement — and because the environment used a
**flat administrative model**, that one support-tier account had a trusted path stretching almost all
the way to the domain's most sensitive systems.

## 🛠️ Mitigation & Hardening
* Reset the exposed credential and audited everywhere it had valid access.
* Implemented a tiered administration model — support-tier credentials can no longer authenticate to
  systems adjacent to Domain Controllers, by design.
* Enabled Credential Guard fleet-wide to reduce credential theft from memory.
* Built standing alerting on any workstation-to-DC-adjacent authentication path, regardless of account.

## 📂 Repository Artifacts
* `queries.spl` — Splunk query building cross-host authentication chains within a short time window.

## 📝 Case Notes
Every individual login in this chain was completely legitimate-looking on its own host. The only way to
see the actual incident was to stop looking at hosts one at a time and build the graph across all of
them — which is exactly what a flat admin model is designed to make catastrophic when it fails.
