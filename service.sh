#!/system/bin/sh
BLOCK_FILE="/data/adb/netblock/blocked_uids.txt"
LOG_FILE="/data/adb/netblock/service.log"
log_msg(){
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
}
log_msg "=== NetBlock Activated ==="
sleep 10
mkdir -p /data/adb/netblock
chmod 755 /data/adb/netblock
touch $BLOCK_FILE
chmod 644 $BLOCK_FILE

setup_chains(){
  # Create chains if don't exist
  iptables -N NETBLOCK 2>/dev/null || iptables -F NETBLOCK
  ip6tables -N NETBLOCK 2>/dev/null || ip6tables -F NETBLOCK
  
  # Insert at top of OUTPUT chain
  iptables -D OUTPUT -j NETBLOCK 2>/dev/null
  iptables -I OUTPUT 1 -j NETBLOCK
  
  ip6tables -D OUTPUT -j NETBLOCK 2>/dev/null
  ip6tables -I OUTPUT 1 -j NETBLOCK
  
  log_msg "Chains initialized"
}

apply_blocks(){
  local count=0
  if [ -f "$BLOCK_FILE" ]; then
    while IFS='|' read -r uid pkg; do
      [ -z "$uid" ] && continue
      [[ "$uid" =~ ^[0-9]+$ ]] || continue
      
      # Block ALL traffic for UID
      # This covers TCP, UDP, ICMP, and any other protocols
      
      # IPv4: Block all protocols
      if ! iptables -C NETBLOCK -m owner --uid-owner "$uid" -j REJECT 2>/dev/null; then
        iptables -A NETBLOCK -m owner --uid-owner "$uid" -j REJECT
        log_msg "Blocked all traffic for UID $uid"
      fi
      
      # IPv6: Block all protocols  
      if ! ip6tables -C NETBLOCK -m owner --uid-owner "$uid" -j REJECT 2>/dev/null; then
        ip6tables -A NETBLOCK -m owner --uid-owner "$uid" -j REJECT
      fi
      
      count=$((count + 1))
    done < "$BLOCK_FILE"
  fi
  log_msg "Applied $count blocks"
}

verify_rules(){
  local test_uid=$(head -1 "$BLOCK_FILE" | cut -d'|' -f1)
  if [ -n "$test_uid" ]; then
    if iptables -L NETBLOCK -n 2>/dev/null | grep -q "owner UID match $test_uid"; then
      log_msg "Rules verified working"
      return 0
    else
      log_msg "Rules not detected, reapplying..."
      return 1
    fi
  fi
  return 0
}

setup_chains
apply_blocks
verify_rules

while true; do
  sleep 30
  if ! iptables -L NETBLOCK -n >/dev/null 2>&1 || ! verify_rules; then
    log_msg "Rules missing, reapplying..."
    setup_chains
    apply_blocks
  fi
done
