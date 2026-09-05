# Case #22: The DNS That Spoke Too Much

**Difficulty:** 🔴 Advanced &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~2 days

## 🚨 Scenario Overview
One host was generating a dramatically higher volume of DNS queries than any comparable machine
on the network — no HTTP anomalies, no unusual outbound connections on any normal port, just DNS.

## 🕵️ First Theory — A Chatty Application
High DNS volume alone isn't unusual — telemetry SDKs and update checkers can be noisy. The first
theory treated it as a misconfigured or overly chatty legitimate application and moved on.

## 🔦 The Detail That Broke It
```
a8f3e91c2b4d.data-sync-cdn.net
7c2b19e0f5a3.data-sync-cdn.net
e4b2c8a1d9f0.data-sync-cdn.net
```

Real applications query a small, stable set of hostnames. This host was querying an endless stream
of **unique, high-entropy, randomly-structured subdomains** against one unfamiliar parent domain —
a pattern no legitimate app produces.

## 🔎 The Real Investigation
Decoding a batch of the subdomain labels revealed encoded fragments that reassembled into
exfiltrated file contents. This was **DNS tunneling**: a covert channel chosen specifically because
outbound DNS traffic is rarely inspected or blocked the way HTTP traffic is, letting the data walk out in
small pieces disguised as routine name lookups.

```spl
index=dns_logs
| eval subdomain_len=len(mvindex(split(query, "."), 0))
| stats count, avg(subdomain_len) as avg_len by src_host, query_domain
| where count > 500 AND avg_len > 20
```

## 🛠️ Mitigation & Hardening
* Blocked the malicious parent domain and sinkholed related lookups for continued monitoring.
* Deployed DNS query-volume and subdomain-entropy anomaly detection as a standing rule.
* Restricted direct outbound DNS from endpoints — all lookups now route through the internal resolver
  only, closing off the unmonitored direct-to-internet DNS path.

## 📂 Repository Artifacts
* `queries.spl` — Splunk query surfacing high-volume, high-entropy subdomain query patterns.

## 📝 Case Notes
Nobody was watching DNS closely because nobody expects it to carry an attack — which is exactly
why it did. The volume was the first clue; the subdomain structure was what actually proved it.
