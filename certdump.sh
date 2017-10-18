#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "usage: $(basename ${0}) site_fqdn" >&2
    exit 0
fi

if [ "$(echo $1 | grep -c "^\([a-zA-Z0-9-]\{1,\}\.\)\{1,\}[a-zA-Z0-9-]\{1,\}$")" -ne 1 ]; then
   echo "usage: $(basename ${0}) site_fqdn" >&2
   exit 1
fi

# echo "\"Certificate CN:\",\"Certificate SAN:\",\"Certificate Serial Number:\""
if ! echo "" | nc -G3 ${1} 443 2>/dev/null; then
    exit 1
fi

# Make sure to user the "-servername" option in case SNI is in place.
if ! echo "" | openssl s_client -connect ${1}:443 -servername ${1} > ${1}.crt 2>/dev/null; then
    # echo "warning: could not get cert for \"${1}\"" >&2
    exit 1
fi

SUBJECT="$(openssl x509 -in ${1}.crt -text 2>/dev/null | grep "Subject: " | sed -e "s/.*CN=//")"
SAN="$(openssl x509 -in ${1}.crt -text 2>/dev/null | grep "Subject Alternative Name:" -A1 | tail -1 | sed -e "s/DNS://g" )"
SERIAL="$(openssl x509 -in ${1}.crt -text 2>/dev/null | grep "Serial Number:" -A1 | tail -1 | sed -e "s/[\t ]//g")"

# Output as quote encapsulated comma separated values (CSV)
echo "\"${SUBJECT}\",\"${SAN}\",\"${SERIAL}\"" | sed -e 's/,"[\t ]*/,"/g'
