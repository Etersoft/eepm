#!/bin/sh -x

# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT="$3"
PKG="$4"

. $(dirname $0)/common.sh

# detect requires by libs
add_libs_requires

if [ -f v8_context_snapshot.bin ] ; then
    echo "electron based application detected, adding requires for it ..."
    add_electron_deps
fi
