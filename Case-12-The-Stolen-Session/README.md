# Case — The Stolen Session

## Executive Summary
An employee account shows an impossible-travel pattern, but authentication logs show no convincing brute-force activity. The investigation determines whether the account, session, or endpoint was compromised.

> **Scenario status:** Simulated / educational DFIR case.
> No real organization, credentials, malware samples, or production systems are involved.

## Investigation Objective
Determine the initial access vector, establish whether an authenticated session was abused, identify affected assets, and produce a defensible timeline.

## Initial Evidence
- IdP/authentication logs
- VPN logs
- Endpoint/browser telemetry
- DNS/proxy records
- Session metadata

## Initial Hypotheses
1. Credential stuffing or password guessing
2. Legitimate travel/VPN artifact
3. Stolen session/token
4. Compromised endpoint

## Investigation Path
1. Build an authentication timeline by user, source IP, device, and session identifier.
2. Correlate the suspicious session with VPN, browser, DNS, and endpoint events.
3. Compare device/browser characteristics before and during the anomalous session.
4. Look for persistence or follow-on access after the session was established.

## Expected Deliverables
- Incident timeline
- Affected users/hosts
- Indicators of compromise or relevant observables
- Evidence-to-conclusion mapping
- Detection opportunities
- Containment and remediation recommendations

## Detection Opportunities
- Impossible-travel correlation
- New device + valid session
- Session reuse from anomalous network
- Authentication followed by sensitive access

## Analyst Notes
This case is intentionally designed around uncertainty and competing hypotheses. The investigator should avoid treating a single alert as proof and should document both supporting and contradictory evidence.

## Final Assessment
The case should conclude with a justified determination of whether the session was abused, what evidence supports that conclusion, and which accounts/devices require containment.

## Suggested MITRE ATT&CK Mapping
Map only techniques supported by the evidence generated during the investigation. Do not assign techniques merely because they are plausible.

---
**Red Kingdom DFIR Case Files**
