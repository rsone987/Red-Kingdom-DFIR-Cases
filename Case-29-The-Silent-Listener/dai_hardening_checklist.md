# Dynamic ARP Inspection (DAI) Hardening Checklist — The Red Kingdom Standard

- [ ] Enable Dynamic ARP Inspection on all access-layer switches
- [ ] Build and maintain a trusted DHCP snooping binding table as the source of truth for DAI
- [ ] Enable port security limiting the number/identity of MAC addresses per switch port
- [ ] Roll out 802.1X port-based authentication for wired network access
- [ ] Disable unused wall ports by default; enable only on request
- [ ] Alert on ARP reply rate anomalies per port, not just binding-table mismatches
