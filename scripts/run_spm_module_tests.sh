#!/usr/bin/env bash

# fail if any commands fails
set -e

# debug log
set -x

pushd Modules/UIComponents && xcodebuild -scheme UIComponents test -destination "platform=iOS Simulator,name=iPhone 8 Plus,OS=14.5" && popd
