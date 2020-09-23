#!/bin/sh
#
#  scripts/carthage-bootstrap-debug.sh
#
#  What It Does
#  ------------
#  Workaround: Carthage builds fails at xcrun lipo on Xcode 12 beta (3,4,5...)
#  https://github.com/Carthage/Carthage/issues/3019

xcconfig=$(mktemp /tmp/static.xcconfig.XXXXXX)
trap 'rm -f "$xcconfig"' INT TERM HUP EXIT

# For Xcode 12 make sure EXCLUDED_ARCHS is set to arm architectures otherwise
# the build will fail on lipo due to duplicate architectures.
# Xcode 12 GM
echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200__BUILD_12A7208 = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig
# Xcode 12 GM 2
echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200__BUILD_12A7209 = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig
echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200 = $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200__BUILD_$(XCODE_PRODUCT_BUILD_VERSION))' >> $xcconfig
echo 'EXCLUDED_ARCHS = $(inherited) $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_$(EFFECTIVE_PLATFORM_SUFFIX)__NATIVE_ARCH_64_BIT_$(NATIVE_ARCH_64_BIT)__XCODE_$(XCODE_VERSION_MAJOR))' >> $xcconfig
echo 'ONLY_ACTIVE_ARCH=NO' >> $xcconfig
echo 'VALID_ARCHS = $(inherited) x86_64' >> $xcconfig
export XCODE_XCCONFIG_FILE="$xcconfig"
echo $XCODE_XCCONFIG_FILE

carthage bootstrap --use-ssh --cache-builds --configuration Debug --platform iOS

exit 0
