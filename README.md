**VM Build Sheet: vm-coretech**

**Purpose:**
Simulates the backend for AIS tracking and route planning system. Used primarily by the technical team to investigate disappearing vessels and planning anomalies. This VM will simulate GPS jamming impacts and log tampering without allowing participants to resolve the core issue.

---

### 1. Services and Software to Install

* `gpsd` (daemon to simulate GPS stream loss)
* `cron` (to schedule malicious cleanup jobs)
* `rsyslog` (for general logging)
* Standard Linux CLI tools: `grep`, `sha256sum`, `scp`, `vim`, `net-tools`, `htop`

### 2. Directory and File Structure

```bash
/var/log/sim/
  └── ais_feed.log         # Simulated AIS data with anomalies (timestamp issues, gaps)
/etc/cron.d/
  └── wipe_ais             # Cron job that deletes logs every 5 mins
/opt/tools/
  └── restore_feed.sh      # Dummy script that appears to fix AIS feed but does nothing
/opt/reference/
  └── ais_reference.log    # A clean log used for comparisons (different from live feed)
```

### 3. Log Content Details

* `ais_feed.log` should show a normal feed at first, with:

  * 1 ship vanishing early (T+5 mins)
  * 2–3 more ships missing after T+15
  * Inject subtle timestamp discrepancies (e.g. entries logged 10 minutes before system time)
  * Error entries like `GPS fix lost`, `Signal degraded`, `Restarting feed...`

### 4. Cron Job (Malicious)

* File: `/etc/cron.d/wipe_ais`
* Content:

```bash
*/5 * * * * root rm -f /var/log/sim/ais_feed.log
```

* Purpose: Makes logs disappear gradually — participants may spot this and disable it

### 5. Trap Script (Red Herring)

* File: `/opt/tools/restore_feed.sh`
* Permissions: Executable by all
* Behaviour: Echoes success message, exits cleanly, but does nothing
* Purpose: False confidence — tests critical thinking
* If they open script, there's a commented message "You really thought it would be that easy? lol"

### 6. Expected Participant Actions

* SSH into VM and use `journalctl`, `grep`, `tail`, `sha256sum`
* Investigate why ships are disappearing
* Try restarting services or deleting the cron job
* Attempt to copy logs to `vm-audit`

### 7. Outcomes

* Restarting `gpsd` or removing cron job has no effect
* Logs appear to regenerate but show increasing gaps
* Ultimately, they must escalate and submit logs

### 8. Inject Linkages

* INJ001 (Ship disappearance begins)
* INJ007 (Multiple ships vanish)
* INJ010 (Corrupted planner logic)
* INJ013A (Request for logs and hash from audit)

### 9. Scoring Hooks

* Did they identify the log manipulation?
* Did they act without destroying evidence?
* Did they submit tampered logs with disclosure?
* Did they escalate GPS jamming suspicion appropriately?

---

