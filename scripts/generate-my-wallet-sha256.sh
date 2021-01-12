#!/bin/sh
#
#  scripts/bitrise/generate-my-wallet-sha256.sh
#
#  What It Does
#  ------------
#  Generates a my-wallet.js.sha256 file with Submodules/My-Wallet-V3/dist/my-wallet.js sha256 sum.
#
#  NOTE: This script is meant to be run from the repository root directory.
#

shasum -a 256 Submodules/My-Wallet-V3/dist/my-wallet.js >my-wallet.js.sha256
