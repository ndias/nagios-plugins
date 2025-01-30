#!/bin/bash

# check_boot, check if a machine crashed
# Version 0.1 - 2025/01/30 - Nuno.Dias@gmail.com 

OK=0
WARNING=1
CRITICAL=2

MSG="OK"
EXIT="$OK"

LOGSIZE=100

if /usr/bin/systemctl is-active auditd --quiet; then

  SIZE=$(grep -E "max_log_file.=" /etc/audit/auditd.conf | cut -d"=" -f2 | tr -d " ")
  if [ "$SIZE" -lt "$LOGSIZE" ]; then

    MSG="Warning: Log Size $SIZE megas, lower than recommended size $LOGSIZE megas"
    EXIT="$WARNING"

  fi
  SHUTDOWN=$(ausearch -i -m system_boot,system_shutdown --start week-ago --end now 2> /dev/null | tail -n 4 | grep -c SYSTEM_SHUTDOWN)
  BOOT=$(ausearch -i -m system_boot,system_shutdown --start week-ago --end now 2> /dev/null | tail -n 4 | grep -c SYSTEM_BOOT)
  if [ "$SHUTDOWN" -ne "$BOOT" ]; then
    TIME=$(ausearch -i  -m system_boot,system_shutdown --start week-ago --end now| tail -n 1 | grep -Eo "\(.+\)")
    MSG="Error: Machine crashed $TIME"
    EXIT="$CRITICAL"
  fi

else
  MSG="Error: auditd not running"
  EXIT="$CRITICAL"
fi

echo "$MSG"
exit "$EXIT"
