#!/bin/bash

# Check the Available memory of a Linux machine
# Nuno.Dias@gmail.com 2022-07-09
# Version 0.4
# License GPLv3

OK=0
WARNING=1
CRITICAL=2
#UNKNOWN=3

#==============================================================================
# Function Usage
#==============================================================================
function usage {

  echo "Usage: $0 -w WARN -c CRIT [-h]"
  echo 
  echo "-w Warning %"
  echo "-c Critical %"
  echo "-h Help"
  exit
}

#==============================================================================
# Function Options
#==============================================================================
function options {

  while getopts "c:w:h" opt; do

    case $opt in
      c) CRIT=$OPTARG;;
      w) WARN=$OPTARG;;
      h) usage;;
      \?) echo "Unknown option: -$OPTARG"
           usage;;
      :) echo "Missing option argument for -$OPTARG"
         usage;;
      *) usage;;
    esac
  done

  if [ ! "$CRIT" ] || [ ! "$WARN" ]; then

    echo "Mandatory option not found!"
    usage

  fi
}

#==============================================================================
# The Program
#==============================================================================
options "$@"

if ! which free > /dev/null 2>&1; then

  echo "Error: free command not found!"
  exit "$UNKNOWN"

fi

TOTAL=$(free | grep Mem | tr -s " " | cut -d" " -f2)
AVAIL=$(free | grep Mem | tr -s " " | cut -d" " -f7)

PER=$(((AVAIL*100)/TOTAL))

echo "OK: Available Memory: ${PER}% (${AVAIL}k)"

if [ "$PER" -le "$CRIT" ]; then
  exit "$CRITICAL"
elif [ "$PER" -le "$WARN" ]; then
  exit "$WARNING"
else
  exit "$OK"
fi
