#!/bin/sh
#
#  scripts/generate_projects.sh
#
#  What It Does
#  ------------
#  zips all dSYMs file from the archive produced when building the app for deployment.
#  Expects a Blockchain.xcarchive to be in the output directory at the root level of the repository

set -ue

cd ../output/Blockchain.xcarchive/dSYMs
zip -r ../../blockchain-dsyms.zip .
