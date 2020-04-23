#!/bin/sh
#
#  NetworkKit/Scripts/get_ssl_certificate.sh
#
#  What It Does
#  ------------
#  Downloads certificate from URL specified in WALLET_SERVER into ${SRCROOT}/NetworkKit/Cert/blockchain.der.

set -ue

if [ ! -d ${SRCROOT}/NetworkKit/Cert ]; then
    echo "Creating ${SRCROOT}/NetworkKit/Cert directory"
    mkdir ${SRCROOT}/NetworkKit/Cert
fi
cd ${SRCROOT}/NetworkKit/Cert

echo "Downloading certificate from ${WALLET_SERVER}:443"
openssl s_client -connect ${WALLET_SERVER}:443 -showcerts -CApath etc/ssl/certs/ | openssl x509 -outform DER > blockchain.der
