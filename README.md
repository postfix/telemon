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
git clone https://github.com/youruser/microserver-telegram-alerts.git /usr/local/bin/microserver-alerts
cd /usr/local/bin/microserver-alerts
chmod +x microserver-alert.sh
```
- Configure credentials in the script header:
```bash
BOT_TOKEN="<YOUR_TELEGRAM_BOT_TOKEN>"
CHAT_ID="<YOUR_TELEGRAM_CHAT_ID>"
```
### Configuration
Edit /usr/local/bin/microserver-alert.sh to adjust:
- Thresholds (e.g., MAX_TEMP for temperature alerts)
- Device list (/dev/sd[b-e], RAID identifiers)
- Additional IPMI checks or SMART attributes

### Scheduling
Enable the cron job for periodic checks (every 10 minutes):
```bash
sudo crontab -e
# Add the line:
*/10 * * * * /usr/local/bin/microserver-alerts/microserver-alert.sh
```
