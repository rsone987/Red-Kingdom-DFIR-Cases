# Live-Boot Forensic Checklist — The Red Kingdom Standard

Use when userspace tools on a running host may not be trustworthy (suspected rootkit).

- [ ] Do not trust `ps`, `netstat`, `lsmod`, or the running kernel's own reporting
- [ ] Boot the host from a known-clean external live-USB image
- [ ] Mount the suspect disk read-only from the clean environment
- [ ] Compare `/lib/modules/` contents against the known-clean module baseline
- [ ] Inspect raw `/proc/<pid>/net/tcp` entries against external network capture
- [ ] Image the disk before any remediation for later analysis
- [ ] Treat the host as unrecoverable in-place — rebuild from a known-clean image
