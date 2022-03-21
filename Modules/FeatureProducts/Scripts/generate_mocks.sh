#!/bin/bash
set -eu

cd "$(dirname "$0")/.."

swift package describe --type json > MockingbirdProject.json

MOCKINGBIRD_PATH="../../SourcePackages/checkouts/mockingbird/mockingbird"

"${MOCKINGBIRD_PATH}" generate --project MockingbirdProject.json \
  --output-dir Tests/FeatureProductsDataTests/Mocks \
  --targets FeatureProductsData \
  --only-protocols \
  --disable-swiftlint

# .mockingbird-ignore not working on CI for some reason
# "${MOCKINGBIRD_PATH}" generate --project MockingbirdProject.json \
#   --output-dir Tests/FeatureProductsDomainTests/Mocks \
#   --targets FeatureProductsDomain \
#   --only-protocols \
#   --disable-swiftlint
