#!/bin/bash

# Check the upsmgBatteryTemperature of MGE UPS using snmp
# Nuno.Dias@gmail.com 2021/02/24 - Version 0.1

function usage {

  echo "Usage: $0 -H hostname -P password -w warning -c critical"
  exit 0
}

function isnumber {

  case $OPTARG in
    [!0-9]* ) echo "Error: -$opt must be an Integer"
              usage;;
  esac

}

while getopts "H:P:w:c:" opt; do
  case $opt in
    H) THEHOST=$OPTARG;;
    P) PASS=$OPTARG;;
    w) isnumber
       WARN=$OPTARG;;
    c) isnumber
       CRIT=$OPTARG;;
    *) usage;;
   esac
done

if [ -z "$THEHOST" ] || [ -z "$PASS" ] || [ -z "$WARN" ] || [ -z "$CRIT" ]; then
  echo "Error: Required option not found"
  usage
fi

if [ "$WARN" -gt "$CRIT" ]; then
  echo "Error: -c must be higher than -w"
  usage
fi

TEMP=$(snmpwalk -v 1 -c "$PASS" "$THEHOST" .1.3.6.1.4.1.705.1.5.7 | cut -d":" -f4 | tr -d " ")

if [ $? -eq 0 ]; then
  if [ "$TEMP" -ge "$CRIT" ]; then
    echo "CRITICAL Temp: ${TEMP} C"
    exit 2
  elif [ "$TEMP" -ge "$WARN" ] && [ "$TEMP" -lt "$CRIT" ]; then
    echo "Warning: ${TEMP} C"
    exit 1
  else
    echo "OK: ${TEMP} C"
    exit 0
  fi 
fi
