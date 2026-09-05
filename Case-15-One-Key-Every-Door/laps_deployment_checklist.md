# Windows LAPS Deployment Checklist — The Red Kingdom Standard

- [ ] Extend AD schema for LAPS attributes (if not already present)
- [ ] Assign LAPS Group Policy to all server and workstation OUs
- [ ] Confirm unique local Administrator passwords are generating and rotating per host
- [ ] Restrict read access to stored LAPS passwords to a small, audited admin group
- [ ] Restrict local Administrator account network logon rights via Group Policy
- [ ] Audit for any remaining hosts with the legacy shared password before closing the rollout
- [ ] Schedule a recurring LAPS coverage audit (quarterly)
