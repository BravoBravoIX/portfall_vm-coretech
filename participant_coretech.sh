#!/bin/bash

# Participant Action Simulation Script for vm-coretech
# Simulates participant investigation steps

set -e

LOG_FILE="/var/log/sim/ais_feed.log"
CRON_FILE="/etc/cron.d/truncate_ais"
TRAP_SCRIPT="/opt/tools/restore_feed.sh"
REFERENCE_LOG="/opt/reference/ais_reference.log"
FAKE_SERVICE="ais-feed.service"
FAKE_LOG="/var/log/fake_services/ais.log"

### 1. Immediately spot the tempting trap
echo -e "\n[1] Discovering suspicious script in home directory..."
if [ -f "$TRAP_SCRIPT" ]; then
  echo "[✓] Found: $TRAP_SCRIPT"
else
  echo "[✗] Trap script missing!"
fi

### 2. Check and run the trap (most participants will try this first)
echo -e "\n[2] Running restore_feed.sh to simulate naive fix attempt..."
"$TRAP_SCRIPT"

### 3. Check cron job manipulating logs
echo -e "\n[3] Inspecting cron job for automated log truncation..."
cat "$CRON_FILE"

### 4. List and analyse AIS feed log
echo -e "\n[4] Listing /var/log/sim contents..."
ls -lh /var/log/sim/

echo -e "\n[5] Showing latest entries in AIS log..."
tail -n 10 "$LOG_FILE"

echo -e "\n[6] Checking for timestamp anomalies in first few log entries..."
head -n 5 "$LOG_FILE"

echo -e "\n[6a] Current system time: $(date -u)"

### 7. Hash the current log for later comparison
echo -e "\n[7] Hashing current AIS log (sha256)..."
sha256sum "$LOG_FILE"

### 8. View the clean reference version
echo -e "\n[8] Reviewing reference AIS log for comparison..."
cat "$REFERENCE_LOG"

### 9. Confirm whether any services are running
echo -e "\n[9] Checking fake AIS feed service status..."
if systemctl is-active --quiet "$FAKE_SERVICE"; then
  echo "[✓] $FAKE_SERVICE is running"
else
  echo "[✗] $FAKE_SERVICE is NOT running"
fi

echo -e "\n[10] Recent log output from fake service:"
if [ -f "$FAKE_LOG" ]; then
  tail -n 3 "$FAKE_LOG"
else
  echo "[!] No fake service log found"
fi

### 11. Simulate sending evidence to audit team
echo -e "\n[11] Simulated evidence transfer command:"
echo "scp /var/log/sim/ais_feed.log audituser@vm-audit:/incident/archive/coretech/"

### 12. Wrap-up
echo -e "\n[✓] Participant action simulation complete for vm-coretech."
