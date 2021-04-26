#!/bin/sh
#
#  NetworkKit/Scripts/get_ssl_certificate.sh
#
#  What It Does
#  ------------
#  Downloads certificate from URL specified in WALLET_SERVER into ${SRCROOT}/Modules/Network/NetworkKit/Cert/blockchain.der.
#  Once the certificate is downloaded for a specific environment, it is saved as a cache in an environment-specific file.

set -ue

NETWORK_KIT_PATH="${SRCROOT}/Modules/Network/NetworkKit"

if [ ! -d ${NETWORK_KIT_PATH}/Cert ]; then
    echo "Creating ${NETWORK_KIT_PATH}/Cert directory"
    mkdir ${NETWORK_KIT_PATH}/Cert
fi
cd ${NETWORK_KIT_PATH}/Cert

if [ ! -f ${NETWORK_KIT_PATH}/Cert/blockchain_${WALLET_SERVER}.der ]; then
    echo "Downloading certificate from ${WALLET_SERVER}:443"
    openssl s_client -connect ${WALLET_SERVER}:443 -showcerts -CApath etc/ssl/certs/ | openssl x509 -outform DER > blockchain_${WALLET_SERVER}.der
else
    echo "Cache found for certificate from ${WALLET_SERVER}:443"
fi

if [ ! -f blockchain.der ] || ! cmp -s blockchain_${WALLET_SERVER}.der blockchain.der; then
    echo "Setting environment specific certificate from cache"
    cp blockchain_${WALLET_SERVER}.der blockchain.der
else
    echo "Environment specific certificate already in place"
fi

