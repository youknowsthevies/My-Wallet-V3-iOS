#!/bin/sh
#
#  scripts/generate_projects.sh
#
#  What It Does
#  ------------
#  Generate projects with xcodegen.
#

if command -v xcodegen 2> /dev/null; then
    xcodegen -s project_blockchain.yml
    xcodegen -s project_modules.yml
else
    echo "(i) xcodegen missing"
fi
