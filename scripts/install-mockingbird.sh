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

MOCKINBIRDPATH="./SourcePackages/checkouts/mockingbird"
if [ -e "$MOCKINBIRDPATH" ]; then
    echo "Installing Mockingbird"   
    (cd "./SourcePackages/checkouts/mockingbird" && make install-prebuilt)
else
    echo "$MOCKINBIRDPATH does not exists. You must resolve packages to './SourcePackages' before running this script."
fi
