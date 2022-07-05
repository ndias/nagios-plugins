#!/bin/bash

# check the status of a drdb device
# version 0.1 - 2022/01/21 - Nuno.Dias@gmail.com
# version 0.2 - 2022/07/05 - Nuno.Dias@gmail.com

OK=0
#WARNING=1
CRITICAL=2
#UNKNOWN=3

DRBDADM="/usr/sbin/drbdadm"

STATUS=$($DRBDADM status | grep "disk:"| cut -d":" -f2| sort | uniq)

if [ "$STATUS" = "UpToDate" ]; then

  echo "DRBD Status OK"
  STATUS=$OK

else
  echo "DRBD Status ERROR"
  STATUS=$CRITICAL
fi

exit $STATUS
