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

# Export LANG
export LANG=en_US.UTF-8
# Export LC_ALL
export LC_ALL=en_US.UTF-8
# Log Gem Environment
gem env
# Update Bundler to Gemfile.lock version
gem install bundler --no-document
# Set Bundler path
bundle config set path 'vendor/bundle'
# Set Bundler install
bundle install
