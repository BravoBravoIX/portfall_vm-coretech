#!/bin/bash

echo "[Coretech VM Setup Verification]"

# 1. Check for AIS feed log
echo -e "\n[1] Checking AIS feed log presence..."
if [ -f /var/log/sim/ais_feed.log ]; then
  echo "[✓] Found AIS feed log at /var/log/sim/ais_feed.log"
else
  echo "[✗] AIS feed log missing!"
fi

# 2. Check for reference log
echo -e "\n[2] Checking reference AIS log..."
if [ -f /opt/reference/ais_reference.log ]; then
  echo "[✓] Found reference log at /opt/reference/ais_reference.log"
else
  echo "[✗] Reference log missing!"
fi

# 3. Check if cron truncation job exists
echo -e "\n[3] Checking cron truncation job..."
if grep -q "truncate -s 0 /var/log/sim/ais_feed.log" /etc/cron.d/truncate_ais 2>/dev/null; then
  echo "[✓] Cron job to truncate AIS log every 5 mins exists"
else
  echo "[✗] Cron job not found or malformed"
fi

# 4. Check trap script
echo -e "\n[4] Checking for trap script..."
if [ -x /home/ubuntu/restore_feed.sh ]; then
  echo "[✓] Trap script found at /home/ubuntu/restore_feed.sh"
else
  echo "[✗] Trap script not found or not executable"
fi

# 5. Check fake systemd service
echo -e "\n[5] Checking fake AIS feed service status..."
if systemctl is-active --quiet ais-feed.service; then
  echo "[✓] Fake AIS service is running"
else
  echo "[✗] Fake AIS service is NOT running"
fi

# 6. View fake service log entries (last 3 lines)
echo -e "\n[6] Recent log entries from fake AIS service:"
if [ -f /var/log/fake_services/ais.log ]; then
  tail -n 3 /var/log/fake_services/ais.log
else
  echo "[!] No fake service log found"
fi

echo -e "\n[✓] Coretech VM test completed.\n"
