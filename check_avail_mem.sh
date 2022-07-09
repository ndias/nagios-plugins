#!/bin/bash

# Check the Available memory of a Linux machine
# Nuno.Dias@gmail.com 2022-07-09 
# Version 0.1
# License GPLv3

OK=0
WARNING=1
CRITICAL=2
#UNKNOWN=3

#==============================================================================
# Function Usage
#==============================================================================
function usage {

  echo "Usage: $0 -w WARN -c CRIT"
  echo 
  echo "-w Warning %"
  echo "-c Critical %"
  exit
}

#==============================================================================
# Function Options
#==============================================================================
function options {

  while getopts "c:w:" opt; do

    case $opt in
      c) CRIT=$OPTARG;;
      w) WARN=$OPTARG;;
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

TOTAL=$(free | grep Mem | tr -s " " | cut -d" " -f2)
AVAIL=$(free | grep Mem | tr -s " " | cut -d" " -f7)

PER=$(((AVAIL*100)/TOTAL))

echo "Available Memory: ${AVAIL}k"

if [ "$PER" -le "$CRIT" ]; then
  exit "$CRITICAL"
elif [ "$PER" -le "$WARN" ]; then
  exit "$WARNING"
else
  exit "$OK"
fi