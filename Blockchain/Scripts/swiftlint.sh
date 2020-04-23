#!/bin/sh
#
#  Blockchain/Scripts/swiftlint.sh
#
#  What It Does
#  ------------
#  Runs swiftlint if it is available.

if which swiftlint > /dev/null; then
    swiftlint
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
