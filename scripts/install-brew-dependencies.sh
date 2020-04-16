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

set -ue

brew install autoconf automake carthage gnu-sed pkg-config swiftlint libtool
