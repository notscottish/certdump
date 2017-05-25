# certdump

This script takes as input a list of FQDNs.

It iterates through these FQDNs, attempting to resolve and connect to each on TCP/443.

Where a connection is successful, OpenSSL is used to grab the cert and dump the Serial Number and Subject Alternative Names.

# Usage

`bash certdump.sh fqdn_list_filename`
