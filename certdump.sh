#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "usage: shootcerts.sh fqdn_list_filename" >&2
    exit 0
fi

if [ ! -f "$1" ]; then
    echo "error: file not found: \"$1\"" >&2
    exit 1
fi

exec 7<"$1"

while read -u 7; do
    if ! echo "" | nc -G3 ${REPLY} 443 2>/dev/null; then
        continue
    fi
    SAN="$(echo "" | openssl s_client -connect ${REPLY}:443 -servername ${REPLY} 2>/dev/null | openssl x509 -text | grep -A1 "Subject Alternative Name:" | tail -1)"
    SERIAL="$(echo "" | openssl s_client -connect ${REPLY}:443 -servername ${REPLY} 2>/dev/null | openssl x509 -text | grep -A1 "Serial Number:" | tail -1)"
    echo "\"${REPLY}\",\"${SAN}\",\"$SERIAL\"" | sed -e "s/ //g"
done
