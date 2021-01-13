#!/bin/sh
#
#  scripts/bitrise/build-generate-js.sh
#
#  What It Does
#  ------------
#  Builds My Wallet V3 and generates a my-wallet.js.sha256 file with Submodules/My-Wallet-V3/dist/my-wallet.js sha256 sum.
#
#  NOTE: This script is meant to be run from the repository root directory.
#

sh scripts/build-js.sh
sh scripts/generate-my-wallet-sha256.sh
