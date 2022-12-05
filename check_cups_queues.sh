#!/bin/bash

# Check the status of a CUPS queue
# Nuno.Dias@gmail.com 2022/12/05
# Version 0.2

RETCODE=0
DISABLED=""

while read -r queue; do

  if lpq -P "$queue" | grep "is not ready" > /dev/null 2>&1; then
    DISABLED="$DISABLED $queue"
    RETCODE=2
  fi
done < <(grep -E "<Printer|<DefaultPrinter" /etc/cups/printers.conf | cut -d" " -f2 | cut -d">" -f1)

if [ "$RETCODE" -eq 2 ]; then 
  echo "Error: Queue$DISABLED disabled"
fi
exit "$RETCODE"
