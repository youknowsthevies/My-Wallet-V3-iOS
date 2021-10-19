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

if command -v mockingbird &> /dev/null
then
    VERSION=$(cat project.yml | grep -A 2 "Mockingbird" | tail -1 | cut -d ":" -f2 | xargs)
    if [ $VERSION == $(mockingbird version) ]; then
        echo "Mockingbird version matches, skipping update"
        exit
    else
        echo "Version mismatch, installing new Mockingbird"
    fi
fi

echo "Installing Mockingbird"

xcodebuild -resolvePackageDependencies

DERIVED_DATA=$(xcodebuild -showBuildSettings | pcregrep -o1 'OBJROOT = (/.*)/Build')
(cd "${DERIVED_DATA}/SourcePackages/checkouts/mockingbird" && make install-prebuilt)
