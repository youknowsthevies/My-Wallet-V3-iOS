#!/bin/sh
#
#  scripts/openssl-build.sh
#
#  What It Does
#  ------------
#  Builds OpenSSL if necessary:
#  Checks that libcrypto.a and libssl.a exist and both contain x86_64 arm64 archs.
#

set -ue

REQUIREDARCHS="x86_64 arm64"
LIBCRYPTO="./Submodules/OpenSSL-for-iPhone/lib/libcrypto.a"
LIBSSL="./Submodules/OpenSSL-for-iPhone/lib/libssl.a"
LIPO_LIBCRYPTO_CMD="lipo $LIBCRYPTO -verify_arch $REQUIREDARCHS"
LIPO_LIBSSL_CMD="lipo $LIBSSL -verify_arch $REQUIREDARCHS"
VALIDLIBCRYPTO=0
VALIDLIBSSL=0

if [ -e "$LIBCRYPTO" ]; then
    echo "$LIBCRYPTO exists"
    if $LIPO_LIBCRYPTO_CMD; then
        VALIDLIBCRYPTO=1
        echo "libcrypto.a contains $REQUIREDARCHS"
    else
        echo "libcrypto.a does not contain $REQUIREDARCHS"
        lipo "$LIBCRYPTO" -info
    fi
else
    echo "$LIBCRYPTO does not exists"
fi

if [ -e "$LIBSSL" ]; then
    echo "$LIBSSL exists"
    if $LIPO_LIBSSL_CMD; then
        VALIDLIBSSL=1
        echo "libssl.a contains $REQUIREDARCHS"
    else
        echo "libssl.a does not contain $REQUIREDARCHS"
        lipo "$LIBSSL" -info
    fi
else
    echo "$LIBSSL does not exists"
fi

if ((VALIDLIBSSL == 0)) || ((VALIDLIBCRYPTO == 0)); then
    echo "Rebuilding OpenSSL"
    cd ./Submodules/OpenSSL-for-iPhone
    sh build-libssl.sh --cleanup --noparallel --archs="$REQUIREDARCHS"
else
    echo "Skiping OpenSSL rebuild"
fi
