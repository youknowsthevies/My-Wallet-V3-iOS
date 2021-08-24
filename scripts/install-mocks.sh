#!/bin/sh
#
#  scripts/generate_mocks.sh
#
#  What It Does
#  ------------
#  Install mock generating script using mockingbird.
#
#  If you need to install mocks to a test target from package source add a line to this script.
#  You can exclude unwanted or problematic sources from being mocked by adding a .mockingbird-ignore file.
#
#  Mocks will be actually generated when you first run tests.

mockingbird install --target AnalyticsKitTests --sources AnalyticsKit --disable-swiftlint