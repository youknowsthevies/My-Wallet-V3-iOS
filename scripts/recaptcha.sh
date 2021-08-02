#!/usr/bin/env sh
#
#  scripts/recaptcha.sh
#
#  What It Does
#  ------------
#  Adds recaptcha and its depedencies if needed.
#

set -e

if [ -z "${BITRISE_PROJECT_PATH}" ]; then
    source .env
fi

CARTHAGE_BUILD_FOLDER=Carthage/Build
RECAPTCHA_FWK_NAME=recaptcha.framework
RECAPTCHA_SHIM_URL=git@github.com:dchatzieleftheriou-bc/recaptchashim.git
RECAPTCHA_URL=${RECAPTCHA_FWK_URL}
TMP_FOLDER=recaptcha_tmp
SHIM_FWK_PATH=recaptchashim
FWK_PATH=recaptcha/SlimClient

dependencies=(GoogleToolboxForMac.xcframework GTMSessionFetcher.xcframework Protobuf.xcframework Promises.xcframework)

mkdir $TMP_FOLDER

if ! shasum -a 256 -c recaptcha.sha256; then
	if [ -z $RECAPTCHA_URL ]; then
		echo "skipping recaptcha integration"
	else
		if [ ! -d $CARTHAGE_BUILD_FOLDER ]; then 
			echo "no carthage folder found"
			rmdir $TMP_FOLDER
			exit 1
		fi

		echo "fetching recaptcha framework"
		curl -L $RECAPTCHA_URL > $TMP_FOLDER/recaptcha.zip

		echo "extracting dowloading archive"
		unzip $TMP_FOLDER/recaptcha.zip -d $TMP_FOLDER/recaptcha
		rm $TMP_FOLDER/recaptcha.zip
	
		if [ -d $CARTHAGE_BUILD_FOLDER/iOS/$RECAPTCHA_FWK_NAME ]; then
			echo "removing existing framework in Carthage folder"
			rm -r $CARTHAGE_BUILD_FOLDER/iOS/$RECAPTCHA_FWK_NAME
		fi

		echo "copying framework to Carthage"
		cp -r $TMP_FOLDER/$FWK_PATH/$RECAPTCHA_FWK_NAME $CARTHAGE_BUILD_FOLDER/iOS
		
		rm -r $TMP_FOLDER/recaptcha
	fi
fi

allFound=true
for i in ${dependencies[@]}; do
	if [ ! -d "$CARTHAGE_BUILD_FOLDER/${i}" ]; then
		echo "dependency $CARTHAGE_BUILD_FOLDER/${i} not found"
		allFound=false
	fi
done

if $allFound; then
	echo "all dependencies found in cache, all done"
	rmdir $TMP_FOLDER
	exit 0
fi

git clone $RECAPTCHA_SHIM_URL $TMP_FOLDER/$SHIM_FWK_PATH

for i in ${dependencies[@]}; do
	echo "copying ${i} to carthage"
	cp -r $TMP_FOLDER/$SHIM_FWK_PATH/Dependencies/${i} $CARTHAGE_BUILD_FOLDER
done

rm -rf $TMP_FOLDER/$SHIM_FWK_PATH
rmdir $TMP_FOLDER
