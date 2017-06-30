#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "usage: $(basename ${0}) fqdn_list_filename" >&2
    exit 0
fi

if [ ! -f "$1" ]; then
    echo "error: file not found: \"$1\"" >&2
    exit 1
fi

# if ! TMPDIR="$(mktemp -d XXXXXX 2>/dev/null)"; then
#     echo "error: temp folder creation failed: \"$TMPDIR\"" >&2
#     exit 1
# fi

exec 7<"$1"

echo "\"Site:\",\"Certificate CN:\",\"Certificate SAN:\",\"Certificate Serial Number:\""

while read -u 7; do
    if [ ${#REPLY} -eq 0 ]; then
        continue
    fi
    
    if ! echo "" | nc -G3 ${REPLY} 443 2>/dev/null; then
        echo "\"${REPLY}\""
        continue
    fi

    if ! echo "" | openssl s_client -connect ${REPLY}:443 -servername ${REPLY} > ${REPLY}.crt 2>/dev/null; then
        # echo "warning: could not get cert for \"${REPLY}\"" >&2
        echo "\"${REPLY}\""
        continue
    fi

	SUBJECT="$(openssl x509 -in ${REPLY}.crt -text 2>/dev/null | grep "Subject: " | sed -e "s/.*CN=//")"
    SAN="$(openssl x509 -in ${REPLY}.crt -text 2>/dev/null | grep "Subject Alternative Name:" -A1 | tail -1 | sed -e "s/DNS://g" )"
    SERIAL="$(openssl x509 -in ${REPLY}.crt -text 2>/dev/null | grep "Serial Number:" -A1 | tail -1 | sed -e "s/[\t ]//g")"

    echo "\"${REPLY}\",\"${SUBJECT}\",\"${SAN}\",\"${SERIAL}\"" | sed -e 's/,"[\t ]*/,"/g'
#    SAN="$(echo "" | openssl s_client -connect ${REPLY}:443 -servername ${REPLY} 2>/dev/null | openssl x509 -text | grep -A1 "Subject Alternative Name:" | tail -1)"
#    SERIAL="$(echo "" | openssl s_client -connect ${REPLY}:443 -servername ${REPLY} 2>/dev/null | openssl x509 -text | grep -A1 "Serial Number:" | tail -1)"
#    echo "\"${REPLY}\",\"${SAN}\",\"$SERIAL\"" | sed -e "s/ //g"
done
