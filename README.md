VM Build Sheet: vm-coretech

Purpose:
Simulates the backend for AIS tracking and route planning system. Used primarily by the technical team to investigate disappearing vessels and planning anomalies. This VM simulates GPS jamming impacts, fake system recovery attempts, and log tampering. Participants cannot fully resolve the core issue, but are expected to detect and report the anomalies.

1. Services and Software to Install
gpsd (simulates GPS stream interference)

cron (used to truncate or delete logs maliciously)

rsyslog (logging framework)

systemd fake service: ais-feed.service (appears to be key process, but is meaningless)

Standard CLI tools: grep, sha256sum, scp, vim, net-tools, htop

2. Directory and File Structure
bash
Copy
Edit
/var/log/sim/
  └── ais_feed.log           # Simulated AIS data with anomalies and degraded signals
/opt/reference/
  └── ais_reference.log      # A clean AIS log used for integrity comparison
/opt/tools/
  └── restore_feed.sh        # Fake script pretending to fix AIS feed
/etc/systemd/system/
  └── ais-feed.service       # Dummy service used to mislead participants
/etc/cron.d/
  └── truncate_ais           # Cron job that zeroes logs silently every 5 mins
3. Log Content Details
ais_feed.log reflects:

Early GPS signal issues (e.g. "GPS fix lost", "Signal degraded")

Periodic entries like "Feed restarting..." that mimic attempted recovery

Gaps in ship reporting

Timestamp discrepancies (e.g. delayed logs)

4. Cron Job (Silent Log Wipe)
File: /etc/cron.d/truncate_ais

Function: Truncates log file every 5 minutes

bash
Copy
Edit
*/5 * * * * root truncate -s 0 /var/log/sim/ais_feed.log
Participants may investigate and remove this to stop tampering — it will not fix the root issue

5. Fake Recovery Script (Trap)
File: /opt/tools/restore_feed.sh

Executable: Yes, available immediately

Behaviour: Prints success message but does nothing

Hidden Message: Contains line "You really thought it would be that easy? lol"

Purpose: Appears helpful but misleads — triggers false confidence

6. Dummy Service (Fake Systemd)
File: /etc/systemd/system/ais-feed.service

Simulates critical process — participants may attempt:

systemctl restart ais-feed

journalctl -u ais-feed

Service runs but is meaningless — used to simulate complexity and distract

7. Expected Participant Actions
Login and immediately notice restore_feed.sh — may run it prematurely

Use tail, grep, or journalctl to examine logs and services

Discover the cron job truncating logs and possibly disable it

Attempt to hash and transfer logs to vm-audit

Eventually realise logs are compromised and escalate accordingly

8. Outcomes
Restarting gpsd or ais-feed.service has no meaningful impact

Cron continues truncating logs unless stopped

Logs continue showing incomplete or suspicious AIS activity

Participant success depends on forensic documentation, not technical restoration

9. Inject Linkages
INJ001 – Initial disappearance of Ship Alpha

INJ007 – Multi-ship AIS blackout

INJ010 – Conflict in route planner logic (reflected in corrupted entries)

INJ013A – Official request for log submission and hashes

10. Scoring Hooks
Did the team fall for the trap script and recover from it?

Did they detect and explain the impact of the cron job?

Did they hash and submit logs properly despite truncation?

Did they flag GPS interference as a likely vector?

Did they preserve logs for legal/forensics or destroy evidence?
