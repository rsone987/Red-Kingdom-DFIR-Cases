# Edge DDoS Mitigation Checklist — The Red Kingdom Standard

- [ ] Public DNS records point through an edge mitigation provider, not directly to origin IP
- [ ] Rate limiting configured at the network edge, ahead of internal firewalls
- [ ] Origin server IP kept out of public records where possible
- [ ] Standing incident playbook: "unreachable service + idle server load" triggers an edge/network
      check first, before any application-level investigation
- [ ] Edge mitigation dashboards included in on-call monitoring rotation
