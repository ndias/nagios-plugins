#!/bin/bash

# Some changes by ndias@lip.pt in 2014/03/13
# Adding checking ip6tables 2016-04-01 ndias@lip.pt version 0.2
# Version 0.2 - Rewrite - 2019/03/08
# Version 0.3 - Capture iptables warnings - 2023/01/16

IPT=""
VER="0.3"

function usage {

  echo
  echo "-4 check if ip6tables is up"
  echo "-6 check if ip6tables is up"
  echo "-v Version"
  echo "-h This help"
  exit 0
}

while getopts "46vh" opt; do
 
  case $opt in
	4) IPT="/sbin/iptables";;
	6) IPT="/sbin/ip6tables";;
        v) echo "check_iptables.sh version $VER"
           exit 0;;
        h) usage;;
 	*) echo "Error Usage: $0 [-4|-6]"
	   usage;;
  esac
done

if [ $# -ne 1 ]; then
 usage
fi

GREP='/bin/grep'
WC='/usr/bin/wc'

STAT=0
OUTPUT=''
CHAINS=$($IPT -nvL 2>&1 | grep -v "# Warning: iptables-legacy tables present, use iptables-legacy to see them" | $GREP Chain | cut -d" " -f2)
TOTAL=0

for CHAIN in $CHAINS ; do

  CNT=$($IPT -S "$CHAIN" 2>&1 | grep -v "# Warning: iptables-legacy tables present, use iptables-legacy to see them" | $WC -l)
  TOTAL=$((TOTAL+CNT-1))

done

  if [ $TOTAL -eq 0 ] ; then
 
    OUTPUT="ERROR: $(echo $IPT | cut -d"/" -f3) no Rules"
    STAT=2

  else

    OUTPUT="OK: $(echo $IPT | cut -d"/" -f3) $TOTAL rules"

  fi

echo "$OUTPUT"

exit $STAT
