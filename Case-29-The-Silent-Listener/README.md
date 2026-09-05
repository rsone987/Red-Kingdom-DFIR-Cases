# Case #29: The Silent Listener — An ARP Poisoning Attack

**Difficulty:** 🔴 Advanced &nbsp;|&nbsp; **Status:** 🟢 Resolved &nbsp;|&nbsp; **Time to Resolution:** ~2 days

## 🚨 Scenario Overview
A handful of employees on the same office floor complained about intermittent, unexplained network
slowness — nothing dramatic, just enough to be annoying, and only affecting that one segment of the
building.

## 🕵️ First Theory — A Flaky Switch
Localized, intermittent slowness on one floor is a classic hardware symptom. The first response was
a routine one: check the switch for errors, check for a duplex mismatch, schedule a hardware swap if
nothing obvious turned up.

## 🔦 The Detail That Broke It
The switch itself reported nothing unusual — no interface errors, no packet loss on its own counters.
If the hardware wasn't the problem, the traffic pattern on the segment needed a closer look.

```bash
$ arp -a
? (10.20.5.1) at aa:bb:cc:11:22:33 [ether] on eth0     # legitimate gateway MAC
? (10.20.5.1) at aa:bb:cc:44:55:66 [ether] on eth0     # conflicting entry, seconds later
```

Two different MAC addresses claiming to be the same gateway IP, flipping back and forth — not a
switch fault. Something on the segment was actively lying about its identity.

## 🔎 The Real Investigation
This is **ARP poisoning**: a device on the same local network segment sent forged ARP replies,
convincing nearby hosts that its own MAC address belonged to the gateway. Traffic that should have
gone straight to the router got routed through the attacker's device first — a classic man-in-the-
middle position, with the "network slowness" being nothing more than the extra hop the attacker's
device added to every intercepted connection.

```bash
$ tcpdump -i eth0 arp
# rapid, repeated ARP replies for 10.20.5.1 from a MAC not matching the router's known address,
# sent every few seconds — far more frequent than legitimate ARP refresh behavior
```

The source device turned out to be an unmanaged laptop that had been connected to a spare wall
port, running an off-the-shelf ARP spoofing tool — intercepting traffic from every host on the
segment, including whatever unencrypted protocols happened to cross the wire in that window.

## 🛠️ Mitigation & Hardening
* Physically disconnected the offending device and preserved it for further review.
* Enabled **Dynamic ARP Inspection (DAI)** on the affected switches, dropping ARP replies that don't
  match a trusted binding table.
* Enabled port security to restrict which MAC addresses are allowed on each wall port.
* Rolled out 802.1X port-based authentication so unmanaged devices can no longer join the network
  by simply plugging into an open port.
* Audited traffic from the intercepted window for any cleartext credentials that may have been
  exposed, and rotated those found.

## 📂 Repository Artifacts
* `arp_conflict_check.sh` — Script to detect conflicting ARP entries for a given gateway IP.
* `dai_hardening_checklist.md` — Standing checklist for enabling ARP-spoofing protections on switches.

## 📝 Case Notes
"Slow network" is one of the most under-investigated complaints in any environment — it's easy to
blame hardware and move on. In this case, the annoyance users noticed was the only visible symptom
of someone quietly sitting in the middle of their traffic.
