#!/bin/sh
#
#  Blockchain/Scritps/get_ssl_certificate.sh
#
#  What It Does
#  ------------
#  Downloads certificate from URL specified in OPENSSL_CERT_URL into ${SRCROOT}/Cert/blockchain.der.

set -ue

if [ ! -d ${SRCROOT}/Cert ]; then
    echo "Creating ${SRCROOT}/Cert directory"
    mkdir ${SRCROOT}/Cert
fi
cd ${SRCROOT}/Cert

echo "Downloading certificate from ${OPENSSL_CERT_URL}:443"
openssl s_client -connect ${OPENSSL_CERT_URL}:443 -showcerts -CApath etc/ssl/certs/ | openssl x509 -outform DER > blockchain.der
