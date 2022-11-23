#!/bin/bash

# Nuno.Dias@gmail.com 2022/11/23
# Version 0.1

function usage {

  echo "Usage: $0 -d DOMAIN -w warning -c critical"
  exit 0
}

function isnumber {

  case $OPTARG in
    [!0-9]* ) echo "Error: -$opt must be an Integer"
              usage;;
  esac

}

while getopts "d:w:c:" opt; do
  case $opt in
    d) DOMAIN=$OPTARG;;
    w) isnumber
       WARN=$OPTARG;;
    c) isnumber
       CRIT=$OPTARG;;
    *) usage;;
   esac
done

if [ -z "$DOMAIN" ] || [ -z "$WARN" ] || [ -z "$CRIT" ]; then
  echo "Error: Required option not found"
  usage
fi

which whois > /dev/null 2>&1 || (echo "whois command not found"; exit)

EXP=$(whois "$DOMAIN" | grep -i "Expiration Date:" | cut -d" " -f3 | awk -F'/' '{print $3"/"$2"/"$1}' | xargs date +%s -d)
TODAY=$(date +%s)

DIF=$((EXP-TODAY))

if [ "$DIF" -lt $((CRIT*86400)) ]; then
    echo "Domain $DOMAIN will expire in $((DIF/86400)) Days"
    exit 2
elif [ "$DIF" -lt $((WARN*86400)) ]; then
    echo "Domain $DOMAIN will expire in $((DIF/86400)) Days"
    exit 1
else
    echo "Domain $DOMAIN will expire in $((DIF/86400)) Days"
    exit 0
fi
