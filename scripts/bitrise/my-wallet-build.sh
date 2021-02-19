#!/bin/sh
#
#  scripts/bitrise/my-wallet-build.sh
#
#  What It Does
#  ------------
#  Build My-Wallet-V3 if necessary
#
#  NODE_VERSION:"7.9.0"
#
#  NOTE: This script is meant to be run in a Bitrise workflow.
#

set -u

WALLETJS="./Submodules/My-Wallet-V3/dist/my-wallet.js"

if [ -e "$WALLETJS" ]; then
	shasum -a 256 -c ./my-wallet.js.sha256
	if [ $? -eq 0 ]; then
		echo "$WALLETJS SHA256 match. Skipping..."
		exit 0
	else
		echo "$WALLETJS SHA256 doesn't match. Cleaning..."
		cd ./Submodules/My-Wallet-V3/
		git clean -xfd
		git reset --hard
		cd ../..
		echo "$WALLETJS SHA256 doesn't match. Building..."
	fi
else
	echo "$WALLETJS does not exists. Building..."
fi

# Install Node
echo "Install Node"
git clone https://github.com/creationix/nvm.git .nvm
cd .nvm
git checkout v0.33.11
. nvm.sh
nvm install $NODE_VERSION
nvm use $NODE_VERSION
if [[ $(npm -v | grep -v "5.6.0") ]]; then
	npm install -g npm@5.6.0
fi
cd ..

# Build JS Dependencies
echo "run scripts/install-js.sh"
sh scripts/install-js.sh
echo "run scripts/build-js.sh"
sh scripts/build-js.sh

# Sanity Check
shasum -a 256 -c ./my-wallet.js.sha256
if [ $? -eq 0 ]; then
	echo "$WALLETJS SHA256 match. Good to go..."
	exit 0
else
	echo "$WALLETJS SHA256 doesn't match. Sanity Check failed..."
	exit 1
fi
