#!/bin/sh
#
#  scripts/generate_projects.sh
#
#  What It Does
#  ------------
#  Generate projects with xcodegen.
#

export COMMIT_HASH=$(git rev-parse --short HEAD)
if command -v xcodegen 2> /dev/null; then
    xcodegen
else
    echo "(i) xcodegen missing"
fi
