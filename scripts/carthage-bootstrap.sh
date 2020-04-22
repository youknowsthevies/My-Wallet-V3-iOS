#!/bin/sh
#
#  scripts/carthage-bootstrap.sh
#
#  What It Does
#  ------------
#  Custom script to bootstrap carthage dependencies, that avoids erroring due to segmentation fault caused by PromiseKit.
#  May want to reconsider the need of this on next Carthage release (current carthage release is 0.34.0)
#  https://github.com/Carthage/Carthage/issues/2760

echo "try carthage bootstrap"
carthage bootstrap --use-ssh --cache-builds --platform iOS || (echo "retry in 5" && sleep 5 && echo "retrying carthage bootstrap" && carthage bootstrap --use-ssh --cache-builds --platform iOS)

sh scripts/move-veriff-sdk.sh
exit 0