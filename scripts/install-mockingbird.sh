#  scripts/install-mockingbird.sh
#
#  What It Does
#  ------------
#  - Install mockingbird CLI from SPM package.
# 

set -ue

xcodebuild -resolvePackageDependencies
DERIVED_DATA=$(xcodebuild -showBuildSettings | pcregrep -o1 'OBJROOT = (/.*)/Build')
(cd "${DERIVED_DATA}/SourcePackages/checkouts/mockingbird" && make install-prebuilt)