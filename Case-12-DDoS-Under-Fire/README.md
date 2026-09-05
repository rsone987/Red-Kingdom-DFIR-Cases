# Case #12: Under Fire — A DDoS at the Edge

**Difficulty:** 🟡 Intermediate &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~6 hours

## 🚨 Scenario Overview
The main web application went unreachable within minutes. Not slow — completely unreachable, for
everyone, everywhere.

## 🕵️ First Theory — A Server-Side Failure
The instinct was to treat it like an application incident: check `web-01`'s resource usage, look for a
runaway process, check for a bad deploy. CPU and memory on the box were nearly idle. The server
wasn't struggling — it was drowning in traffic that never even got the chance to reach it.

```bash
$ top
%Cpu(s): 2.1 us, 0.8 sy ... — nothing unusual here
```

## 🔦 The Detail That Redirected It
A perfectly healthy server behind a completely unreachable service means the problem isn't on the
server at all — it's upstream, on the path traffic takes to get there.

```spl
index=router_logs sourcetype="linux:firewall"
| stats count by src_ip
| sort - count
| head 20
```

Thousands of distinct source IPs, each sending a modest amount of traffic — individually invisible,
collectively enough to saturate the router's bandwidth before a single legitimate request could get
through.

## 🔎 The Real Investigation
This was a volumetric **Distributed Denial of Service** attack. No exploit, no clever technique — just
overwhelming scale aimed at the network layer itself, not the application. Hardening `web-01` further
would have changed nothing, because `web-01` was never actually under attack. The router in front of
it was.

## 🛠️ Mitigation & Hardening
* Routed public traffic through an edge DDoS mitigation service (Cloudflare-style), so malicious
  volume gets filtered before it ever reaches our network.
* Configured rate limiting at the network edge, ahead of `router-fw`.
* Documented a standing incident playbook: any "server is unreachable but shows no load"
  symptom now triggers an edge/network-layer check first, before touching the server at all.

## 📂 Repository Artifacts
* `queries.spl` — Splunk query used to confirm the volumetric, distributed-source traffic pattern.
* `edge_mitigation_checklist.md` — Standing checklist for enabling edge-layer DDoS protection.

## 📝 Case Notes
The fastest resolution in this series so far, precisely because the first instinct was resisted quickly:
a healthy server under an unreachable service is a routing problem, not an application problem.
Good security sometimes means protecting the edge, not the box.
