#!/bin/sh
#
#  scripts/install-brew-dependencies.sh
#
#  What It Does
#  ------------
#  Install brew dependencies.
#
#  NOTE: Some of these dependencies are needed to build `libwally-core`
#

set -u

brew install autoconf automake carthage gnu-sed pkg-config swiftlint libtool xcodegen
