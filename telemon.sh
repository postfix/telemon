#!/usr/bin/env bash
# telemon — cron-driven health checks with Telegram alerts

set -euo pipefail
IFS=$'\n\t'

### ────── Load configuration ──────
CONF="/etc/telemon.conf"
if [[ ! -r $CONF ]]; then
  echo "ERROR: Missing or unreadable config: $CONF" >&2
  exit 1
fi
# shellcheck source=/dev/null
source "$CONF"

: "${BOT_TOKEN:?Missing BOT_TOKEN in $CONF}"
: "${CHAT_ID:?Missing CHAT_ID in $CONF}"
: "${MAX_TEMP:?Missing MAX_TEMP in $CONF}"

TELEGRAM_API="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage"

### ────── Helpers ──────

_alert() {
  local msg="${1//\"/\\\"}"  # escape quotes
  curl --silent --show-error --fail --max-time 10 \
       "$TELEGRAM_API" \
       -d chat_id="$CHAT_ID" \
       -d parse_mode=Markdown \
       -d text="$msg" \
    || echo "WARN: Telegram API call failed" >&2
}

### ────── Check 1: RAID health ──────
if raid_status=$(
     grep -E 'md[0-9]+ .* \[[0-9U_]+(\s*,\s*[0-9U_]+)*\]' /proc/mdstat \
       | awk '/_[U ]/ {print}'
   ); then
  _alert "*🚨 RAID degraded!*  
\`\`\`
$raid_status
\`\`\`"
fi

### ────── Check 2: SMART status ──────
for ata in /dev/disk/by-id/*-ata-*; do
  [[ -b $ata ]] || continue
  if ! smartctl -H "$ata" 2>&1 | grep -q 'PASSED'; then
    smart_out=$(smartctl -H "$ata" 2>&1 | sed 's/^/    /')
    _alert "*🚨 SMART failure on* \`$ata\`!*  
\`\`\`
$smart_out
\`\`\`"
  fi
done

### ────── Check 3: IPMI temperatures ──────
mapfile -t highs < <(
  ipmitool sdr type temperature 2>/dev/null \
    | awk -v M="$MAX_TEMP" \
          '$4 ~ /^[0-9]+(\.[0-9]+)?$/ && $4 > M'
)
if (( ${#highs[@]} > 0 )); then
  msg="🚨 *High temperatures detected!*"
  for line in "${highs[@]}"; do
    msg+="  
\`\`$line\`\`"
  done
  _alert "$msg"
fi

exit 0
