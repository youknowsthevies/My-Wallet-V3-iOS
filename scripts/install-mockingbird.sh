#  scripts/install-mockingbird.sh
#
#  What It Does
#  ------------
#  - Install mockingbird CLI from SPM package.
# 

set -ue

if ! command -v pcregrep &> /dev/null
then
    brew install pcre
fi

if ! command -v mockingbird &> /dev/null
then
    xcodebuild -resolvePackageDependencies
    
    DERIVED_DATA=$(xcodebuild -showBuildSettings | pcregrep -o1 'OBJROOT = (/.*)/Build')
    (cd "${DERIVED_DATA}/SourcePackages/checkouts/mockingbird" && make install-prebuilt)
    exit
fi
