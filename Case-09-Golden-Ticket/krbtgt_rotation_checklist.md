# krbtgt Rotation Checklist — The Red Kingdom Standard

- [ ] Confirm current replication health across all Domain Controllers before starting
- [ ] Perform the FIRST krbtgt password reset
- [ ] Allow full AD replication to complete across all DCs
- [ ] Wait at least one full ticket-lifetime cycle (per domain policy)
- [ ] Perform the SECOND krbtgt password reset (required — a single reset is not sufficient)
- [ ] Allow full AD replication to complete again
- [ ] Audit Domain Admins group membership immediately after rotation
- [ ] Schedule recurring krbtgt rotation as standing policy, not incident-only practice
