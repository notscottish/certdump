# certdump

This script takes as input a single FQDN.

It then:

* resolves the FQDN to an IP
* checks that port TCP/443 is open
* connects TCP/443 and uses OpenSSL to grab the cert and dump the Serial Number and Subject Alternative Names.

Note: The OpenSSL connect attempt will use SNI.

# Usage

`bash certdump.sh fqdn`
