#!/bin/sh
#
#  NetworkKit/Scripts/get_ssl_certificate.sh
#
#  What It Does
#  ------------
#  Downloads certificate from URL specified in WALLET_SERVER into ${SRCROOT}/Modules/Network/NetworkKit/Cert/blockchain.der.

set -ue

NETWORK_KIT_PATH="${SRCROOT}/Modules/Network/NetworkKit"

if [ ! -d ${NETWORK_KIT_PATH}/Cert ]; then
    echo "Creating ${NETWORK_KIT_PATH}/Cert directory"
    mkdir ${NETWORK_KIT_PATH}/Cert
fi
cd ${NETWORK_KIT_PATH}/Cert

echo "Downloading certificate from ${WALLET_SERVER}:443"
openssl s_client -connect ${WALLET_SERVER}:443 -showcerts -CApath etc/ssl/certs/ | openssl x509 -outform DER > blockchain.der
