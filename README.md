# telemon
 Lightweight Telegram‑based monitoring solution for my HP MicroServer Gen8: cron‑driven RAID, SMART, and IPMI health checks with real‑time alerting via Telegram Bot.

This sript implements a simple, no‑overhead monitoring system for HP ProLiant MicroServer Gen8 using standard Linux tools and Telegram for notifications. Rather than deploying a full Prometheus/Grafana stack, it uses a cron‑driven Bash script to perform:
- RAID health checks (mdadm)
- SMART disk status (smartctl)
- IPMI sensor readings (temperatures, fans) via ipmitool

When any check indicates a failure or out‑of‑range value, the script sends a formatted alert message to a configured Telegram chat using a Telegram Bot API.
Features:
- ❗️ RAID Degradation Alerts: Detects missing or failed disks in software RAID arrays.
- ❗️ SMART Failure Notifications: Monitors overall SMART health for each HDD/SSD.
- ❗️ Thermal Alerts: Reads IPMI temperature sensors and notifies on high readings.
- 📱 Realtime Alerts: Uses Telegram Bot API for push notifications to phone or group.
- 🚀 Lightweight: No persistent services; single cron job, no database or dashboard.

### Prerequisites
Debian‑based OS on target MicroServer Gen8 mdadm, smartmontools, ipmitool, curl, jq installed on the server
Telegram Bot Token and Chat ID configured

### Installation
- Install dependencies:
```bash
sudo apt update
sudo apt install -y mdadm smartmontools ipmitool curl jq
```
- Clone this repository into /usr/local/bin or your preferred location:
```bash
git clone https://github.com/postfix/telemon.git /usr/local/bin/telemon
chmod +x /usr/local/bin/telemon
```

### Configuration
Edit /etc/telemon.conf to adjust:
- Credential
- Thresholds (e.g., MAX_TEMP for temperature alerts)
- Device list (/dev/sd[b-e], RAID identifiers)
- Additional IPMI checks or SMART attributes
```bash
# /etc/telemon.conf
# ===========================
# Configuration for microserver-alert.sh
# Must be owned by root and mode 600.

# Telegram Bot API token (keep this secret)
BOT_TOKEN="123456789:ABCDEF-your-actual-bot-token-here"

# Telegram chat ID to send alerts to (user or group)
CHAT_ID="123456456"

# Thresholds
# MAX_TEMP: any sensor reading strictly above this (°C) triggers an alert
MAX_TEMP=65
```
```
chown root:root /etc/telemon.conf
chmod 600 /etc/telemon.conf
```
### Scheduling
Enable the cron job for periodic checks (every 5 minutes):
```bash
sudo crontab -e
# Add the line:
*/5 * * * * /usr/local/bin/microserver-alerts/microserver-alert.sh
```
