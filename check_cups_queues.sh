#!/bin/bash

# Check the status of a CUPS queue
# Nuno.Dias@gmail.com 2022/11/23
# Version 0.1

grep -E "<Printer|<DefaultPrinter" /etc/cups/printers.conf | cut -d" " -f2 | cut -d">" -f1 | \
while read -r queue; do

  if lpq -P "$queue" | grep "is not ready" > /dev/null 2>&1; then
    echo "Error: Queue $queue disabled"
    exit 2
  fi
done

exit 0
