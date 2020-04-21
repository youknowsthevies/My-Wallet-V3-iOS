#!/bin/sh
#
#  scripts/carthage-bootstrap.sh
#
#  What It Does
#  ------------
#  Custom script to bootstrap cartaghe dependencies to avoid exception due to Firebase/Protobuf.
#

carthage bootstrap --use-ssh --cache-builds --platform iOS FirebaseAnalyticsBinary &&
    carthage bootstrap --use-ssh --cache-builds --platform iOS FirebaseCrashlyticsBinary &&
    carthage bootstrap --use-ssh --cache-builds --platform iOS FirebaseDynamicLinksBinary &&
    carthage bootstrap --use-ssh --cache-builds --platform iOS FirebaseRemoteConfigBinary &&
    carthage bootstrap --use-ssh --cache-builds --platform iOS FirebaseMessagingBinary &&
    carthage bootstrap --use-ssh --cache-builds --platform iOS

sh scripts/move-veriff-sdk.sh
