#!/bin/sh
#
#  scripts/install-brew-dependencies.sh
#
#  What It Does
#  ------------
#  Install brew dependencies.
#

set -u

HOMEBREW_NO_AUTO_UPDATE=1 brew bundle install
