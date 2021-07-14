#!/bin/sh
#
#  scripts/generate-recaptcha-sha256.sh
#
#  What It Does
#  ------------
#  Generates a recaptcha.sha256 file with Carthage/Build/iOS/recaptcha.framework sha256 sum.
#
#  NOTE: This script is meant to be run from the repository root directory.
#

shasum -a 256 Carthage/Build/iOS/recaptcha.framework/recaptcha >recaptcha.sha256
