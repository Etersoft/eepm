#!/bin/sh -x

# Default repack script (used if a special script for target product is mieed)

# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT="$3"
PKG="$4"

. $(dirname $0)/common.sh

# detect requires by libs
add_libs_requires

add_bin_exec_command

# TODO: add product dir detection
if [ -f $PRODUCTDIR/v8_context_snapshot.bin ] ; then
    echo "electron based application detected, adding requires for it ..."
    add_electron_deps
fi
