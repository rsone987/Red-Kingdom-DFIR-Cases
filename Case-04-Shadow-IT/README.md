# Case #04: The Forgotten Door — A Shadow IT Server

**Difficulty:** 🟡 Intermediate &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~2 days

## 🚨 Scenario Overview
A routine external scan flagged an open port on a public IP that didn't appear anywhere in the asset
inventory. No ticket, no owner, no name — just a listening service where nothing was supposed to be.

## 🕵️ First Theory — Scanner Noise
Unregistered IPs show up more often than you'd think, usually from scanner misconfiguration or a
decommissioned lease that hadn't expired yet. I logged it as likely noise and moved on to the actual
backlog.

## 🔦 The Detail That Reopened It
Three days later, an unrelated alert showed lateral movement attempts against an internal file
server — originating from that exact "noise" IP. It wasn't decommissioned. It was alive, and now it
was moving.

```bash
$ nmap -sV -p- 203.0.113.44
203.0.113.44 — Port 8080/tcp open — nginx 1.14.0 (2018 release)
```

Nginx from 2018. Nobody runs that on purpose in a modern stack — unless nobody's looked at it in
years.

## 🔎 The Real Investigation
DHCP lease history and internal Git commit logs traced it back to a proof-of-concept a developer
spun up **six months earlier**, never registered with IT, never patched, and forgotten the moment the
demo it was built for ended.

```spl
index=asset_inventory NOT [ | inputlookup known_assets.csv | fields ip ]
| dedup ip
| table ip, first_seen, last_seen
```

The unpatched nginx build carried a known, public CVE. It had been sitting exposed for months —
plenty of time for it to become someone's first foothold before anyone noticed it existed.

## 🛠️ Mitigation & Hardening
* Decommissioned the server and rotated every credential it had touched.
* Built a continuous **Asset Discovery** process: scheduled network sweeps cross-referenced against
  the official CMDB, flagging anything unregistered automatically.
* Required every new server — including proofs-of-concept — to be registered before it gets a
  routable IP.

## 📂 Repository Artifacts
* `asset_discovery_scan.sh` — Network sweep script that diffs live hosts against the known-asset list.
* `queries.spl` — Splunk query surfacing traffic from unregistered IPs.

## 📝 Case Notes
The biggest threat was never the hardened production server — it was the one nobody remembered
existed. Convenient dismissals are how shadow IT survives long enough to matter.
