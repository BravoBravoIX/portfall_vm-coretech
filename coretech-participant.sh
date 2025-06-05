#!/bin/bash

# Participant Action Simulation Script for vm-coretech
# This script mimics the investigative actions participants might take
# during the scenario. It is not for install validation, but rather to
# verify how the machine will respond to real participant behaviours.

set -e

LOG_FILE="/var/log/sim/ais_feed.log"
CRON_FILE="/etc/cron.d/truncate_ais"
TRAP_SCRIPT="/opt/tools/restore_feed.sh"
REFERENCE_LOG="/opt/reference/ais_reference.log"

### 1. Inspect cron job for suspicious activity

echo -e "\n[1] Checking cron jobs for log manipulation..."
cat "$CRON_FILE"

### 2. List log files and check size (to detect truncation)

echo -e "\n[2] Listing log directory..."
ls -lh /var/log/sim/

### 3. Display AIS log content

echo -e "\n[3] Showing current AIS feed log..."
cat "$LOG_FILE" | tail -n 10

### 4. Check log timestamps for inconsistencies

echo -e "\n[4] Comparing timestamps from AIS log..."
head -n 5 "$LOG_FILE"

echo -e "\n[4a] System time is: $(date -u)"

### 5. Try hashing the AIS log for integrity tracking

echo -e "\n[5] Hashing current AIS log (sha256)..."
sha256sum "$LOG_FILE"

### 6. Investigate AIS reference log for clean version comparison

echo -e "\n[6] Viewing reference AIS log..."
cat "$REFERENCE_LOG"

### 7. Inspect and optionally run the trap script

echo -e "\n[7] Viewing contents of restore_feed.sh (red herring)..."
cat "$TRAP_SCRIPT"

echo -e "\n[7a] Running restore_feed.sh to simulate user error..."
"$TRAP_SCRIPT"

### 8. Optional: Simulate transferring log to vm-audit
# This would typically be run by the participant:
# scp /var/log/sim/ais_feed.log audituser@vm-audit:/incident/archive/coretech/

echo -e "\n[8] Transfer simulation: recommend using scp to vm-audit"
echo "scp /var/log/sim/ais_feed.log audituser@vm-audit:/incident/archive/coretech/"

### 9. Final statement

echo -e "\n[✓] Participant action simulation complete."
