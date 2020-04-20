#!/bin/sh
#
#  scripts/bitrise/install-gems.sh
#
#  What It Does
#  ------------
#  Install ruby and necessary gems.
#
#  NOTE: This script is meant to be run in a Bitrise workflow.
#

set -u

brew update && brew upgrade ruby-build
rbenv install 2.6.5
rbenv global 2.6.5

# Install Ruby Gems
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
gem env
gem cleanup
gem install bundler --no-document
gem update bundler --no-document
gem install xcpretty --no-document
bundle install --path vendor/bundle
bundle clean
