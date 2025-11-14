#!/bin/bash

# Check the HW sensors by IPMI
# Nuno.Dias@gmail.com - Version 0.5 - 2025/11/14

SENSORS="/usr/sbin/ipmi-sensors"
SEL="/usr/sbin/ipmi-sel"

OK=0
#WARNING=1
CRITICAL=2
#UNKNOWN=3
EXIT="$OK"
LANPLUS="false"

###########################################################################
# Function usage
###########################################################################
function usage {

  echo "Usage: $0 -h HOSTNAME -u Username -p Password [-i]"
  echo 
  echo "-i lanplus "
  echo
  exit 1

}

###########################################################################
# Function Options
###########################################################################
function options {

  if [ $# -lt 3 ]; then
    usage
  fi

  while getopts "h:u:p:i" opt; do

    case $opt in

      h) HOST=$OPTARG;;
      u) USER=$OPTARG;;
      p) PASSWORD=$OPTARG;;
      i) LANPLUS="true";;
      *) echo "Invalid option ..."
         usage;;
    esac

  done
}

###########################################################################
# Function sun
###########################################################################
function sun {

	if IPMT=$(/usr/bin/ipmitool -H "$HOST" -v -I lanplus -U "$USER" -C 3 -P "$PASSWORD"  chassis status 2> /dev/null); then
	       	if echo "$IPMT" | grep -E "off|true"; then
			EXIT="$CRITICAL"
		fi
	else
		echo "Connection Error"
		EXIT="$CRITICAL"
	fi
}

###########################################################################
# Function sensors
###########################################################################
function sensors {

  RES_SENSORS=$($SENSORS -h "$HOST" -u "$USER" -p "$PASSWORD" \
--ignore-not-available-sensors --ignore-unrecognized-events --no-header-output \
--comma-separated-output 2>&1 | "$GREPEXP")
}

###########################################################################
# Main Program
###########################################################################
options "$@"

if "$LANPLUS"; then
  sun
else
  GREPEXP="grep -Ev \"'State Deasserted'|'Entity Present'|\
'Cable/Interconnect is connected'|'Processor Presence detected'|\
'Presence detected'|'Fully Redundant'|'Drive Presence'|'OK'|\
'Limit Not Exceeded'|'Device Inserted/Device Present'|'S0/G0'|\
'Log Area Reset/Cleared'|'Legacy ON state'\""
  sensors

  if echo "$RES_SENSORS" | grep -i "Redundancy Lost"; then
    GREPEXP="grep -cE \"Power Supply.*'OK'$\""
    sensors
    N=sensors
    if [ "$N" = 1 ]; then
      GREPEXP="grep -Ev \"'State Deasserted'|'Entity Present'|\
'Cable/Interconnect is connected'|'Processor Presence detected'|\
'Presence detected'|'Fully Redundant'|'Drive Presence'|'OK'|\
'Limit Not Exceeded'|'Device Inserted/Device Present'|'S0/G0'|\
'Log Area Reset/Cleared'|'Legacy ON state'|\
PSRed Status.*Power Unit.*'Redundancy Lost'\""
      sensors
    fi
  fi
  RES_SEL=$($SEL -h "$HOST" -u "$USER" -p "$PASSWORD" --comma-separated-output \
--no-header-output | grep -Ev "Log Area Reset/Cleared" 2>&1)

  if [ "$RES_SENSORS" != "" ]; then
    echo "SENSORS::$RES_SENSORS"
    EXIT="$CRITICAL"
  fi

  if [ "$RES_SEL" != "" ]; then
    echo "$OUTPUT SEL::$RES_SEL"
    EXIT="$CRITICAL"
  fi
fi

if [ "$EXIT" -eq 0 ]; then
  echo "OK"
fi

exit $EXIT
