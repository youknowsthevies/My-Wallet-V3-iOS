#!/bin/bash
set -eu

cd "$(dirname "$0")/.."

swift package describe --type json > MockingbirdProject.json

MOCKINGBIRD_PATH="../../SourcePackages/checkouts/mockingbird/mockingbird"

"${MOCKINGBIRD_PATH}" generate --project MockingbirdProject.json \
  --output-dir Tests/AnalyticsKitTests \
  --targets AnalyticsKit \
  --only-protocols \
  --disable-swiftlint
