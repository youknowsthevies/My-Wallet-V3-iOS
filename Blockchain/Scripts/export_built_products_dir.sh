#!/bin/sh
#
#  Blockchain/Scritps/export_built_products_dir.sh
#
#  What It Does
#  ------------
#  Exports $BUILT_PRODUCTS_DIR to envman as $BC_BUILT_PRODUCTS_DIR
#  BC_BUILT_PRODUCTS_DIR is used in BitRise workflows.

if command -v envman 2> /dev/null; then
    BC_BUILT_PRODUCTS_DIR="${BUILT_PRODUCTS_DIR}"
    echo "(i) BC_BUILT_PRODUCTS_DIR: $BC_BUILT_PRODUCTS_DIR"
    envman add --key BC_BUILT_PRODUCTS_DIR --value "${BC_BUILT_PRODUCTS_DIR}"
else
    echo "(i) envman missing"
fi
