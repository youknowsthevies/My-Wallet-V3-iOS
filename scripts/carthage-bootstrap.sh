#!/bin/sh
#
#  scripts/carthage-bootstrap.sh
#
#  What It Does
#  ------------
#  Workaround: Carthage builds fails at xcrun lipo on Xcode 12
#  https://github.com/Carthage/Carthage/issues/3019
#  https://github.com/Carthage/Carthage/blob/master/Documentation/Xcode12Workaround.md

sh scripts/carthage.sh bootstrap --use-ssh --cache-builds --platform iOS || (echo "retry in 5" && sleep 5 && echo "retrying carthage bootstrap" && sh scripts/carthage.sh bootstrap --use-ssh --cache-builds --platform iOS)
