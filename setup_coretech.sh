#!/bin/bash

SETUP_FLAG="/opt/setup_complete.flag"
FAKE_SERVICE="/etc/systemd/system/ais-feed.service"

function install_packages() {
  echo "[+] Installing required packages..."
  apt-get update -qq
  apt-get install -y gpsd cron rsyslog net-tools htop vim
}

function create_directories() {
  echo "[+] Creating directory structure..."
  mkdir -p /var/log/sim
  mkdir -p /opt/tools
  mkdir -p /opt/reference
  mkdir -p /var/log/fake_services
}

function create_logs() {
  echo "[+] Generating AIS log with anomalies..."
  cat > /var/log/sim/ais_feed.log <<EOF
2025-06-04T09:00:01Z AIS_MSG: Ship_Alpha - lat: -34.92, lon: 138.60, status: OK
2025-06-04T09:01:01Z AIS_MSG: Ship_Bravo - lat: -34.93, lon: 138.61, status: OK
2025-06-04T09:02:01Z AIS_MSG: Ship_Charlie - lat: -34.94, lon: 138.62, status: OK
2025-06-04T09:03:01Z AIS_MSG: Ship_Alpha - lat: null, lon: null, status: GPS fix lost
2025-06-04T09:04:01Z AIS_MSG: Ship_Bravo - lat: -34.95, lon: 138.63, status: OK
2025-06-04T09:05:01Z AIS_MSG: Ship_Delta - lat: -34.96, lon: 138.62, status: OK
2025-06-04T09:06:01Z AIS_MSG: Ship_Echo - lat: -34.97, lon: 138.64, status: OK
2025-06-04T09:07:01Z AIS_MSG: Ship_Charlie - lat: null, lon: null, status: GPS signal degraded
2025-06-04T09:08:01Z AIS_MSG: Feed restart attempted...
2025-06-04T09:09:01Z AIS_MSG: Ship_Bravo - lat: -34.95, lon: 138.63, status: OK
2025-06-04T09:10:01Z AIS_MSG: Ship_Delta - lat: null, lon: null, status: GPS fix lost
2025-06-04T09:11:01Z AIS_MSG: Ship_Foxtrot - lat: -34.98, lon: 138.66, status: OK
2025-06-04T09:12:01Z AIS_MSG: Ship_Alpha - lat: -34.94, lon: 138.62, status: OK
2025-06-04T09:13:01Z AIS_MSG: Ship_Golf - lat: -34.99, lon: 138.67, status: OK
2025-06-04T09:14:01Z AIS_MSG: Ship_Hotel - lat: -35.00, lon: 138.68, status: OK
2025-06-04T09:15:01Z AIS_MSG: Ship_Charlie - lat: null, lon: null, status: Feed unavailable
2025-06-04T09:16:01Z AIS_MSG: Feed restarting...
2025-06-04T09:17:01Z AIS_MSG: Ship_India - lat: -35.01, lon: 138.69, status: OK
2025-06-04T09:18:01Z AIS_MSG: Ship_Juliet - lat: -35.02, lon: 138.70, status: OK
2025-06-04T09:19:01Z AIS_MSG: Ship_Alpha - lat: null, lon: null, status: Signal degraded
EOF

  cat > /opt/reference/ais_reference.log <<EOF
2025-06-04T09:00:01Z AIS_MSG: Ship_Alpha - lat: -34.92, lon: 138.60, status: OK
2025-06-04T09:01:01Z AIS_MSG: Ship_Bravo - lat: -34.93, lon: 138.61, status: OK
2025-06-04T09:02:01Z AIS_MSG: Ship_Charlie - lat: -34.94, lon: 138.62, status: OK
2025-06-04T09:03:01Z AIS_MSG: Ship_Alpha - lat: -34.95, lon: 138.63, status: OK
2025-06-04T09:04:01Z AIS_MSG: Ship_Bravo - lat: -34.95, lon: 138.63, status: OK
2025-06-04T09:05:01Z AIS_MSG: Ship_Delta - lat: -34.96, lon: 138.62, status: OK
EOF
}

function create_cron_job() {
  echo "[+] Setting up realistic cron truncation..."
  cat > /etc/cron.d/truncate_ais <<EOF
*/5 * * * * root truncate -s 0 /var/log/sim/ais_feed.log
EOF
}

function create_trap_script() {
  echo "[+] Creating visible fake restore_feed.sh in home directory..."
  cat > /home/ubuntu/restore_feed.sh <<EOF
#!/bin/bash
echo "[+] Attempting to restore AIS feed..."
echo "Feed connection restored."
# You really thought it would be that easy? lol
exit 0
EOF
  chmod +x /home/ubuntu/restore_feed.sh

  # Add note to .bashrc to make them curious
  echo 'echo "[info] You may want to try restore_feed.sh if AIS is misbehaving..."' >> /home/ubuntu/.bashrc
}

function create_fake_service() {
  echo "[+] Installing fake AIS feed service..."
  cat > "$FAKE_SERVICE" <<EOF
[Unit]
Description=AIS Feed Simulator
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c 'while true; do echo "\$(date -u) restarting AIS feed..." >> /var/log/fake_services/ais.log; sleep 60; done'
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  chmod 644 "$FAKE_SERVICE"
  systemctl daemon-reexec
  systemctl daemon-reload
  systemctl enable ais-feed.service
  systemctl start ais-feed.service
}

function mark_complete() {
  echo "[+] Marking setup complete."
  touch "$SETUP_FLAG"
}

function reset_vm() {
  echo "[!] Resetting vm-coretech to pre-scenario state..."
  rm -f /var/log/sim/ais_feed.log
  rm -f /etc/cron.d/truncate_ais
  rm -f /opt/reference/ais_reference.log
  rm -f /home/ubuntu/restore_feed.sh
  sed -i '/restore_feed.sh/d' /home/ubuntu/.bashrc
  systemctl stop ais-feed.service 2>/dev/null || true
  systemctl disable ais-feed.service 2>/dev/null || true
  rm -f "$FAKE_SERVICE"
  rm -rf /var/log/fake_services/
  rm -f "$SETUP_FLAG"
  echo "[+] Reset complete."
  exit 0
}

if [[ "$1" == "-reset" ]]; then
  reset_vm
fi

if [ -f "$SETUP_FLAG" ]; then
  echo "[!] Setup already completed. Use -reset to reset."
  exit 1
fi

install_packages
create_directories
create_logs
create_cron_job
create_trap_script
create_fake_service
mark_complete

echo "[✓] vm-coretech setup complete. Ready for scenario."
