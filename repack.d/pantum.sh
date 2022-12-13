#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PRODUCT=pantum

. $(dirname $0)/common.sh

if [ "$($DISTRVENDOR -b)" = "64" ] ; then
    remove_dir /usr/lib/sane
    # keep /usr/lib64
else
    remove_dir /usr/lib64/sane
    # keep /usr/lib
fi

# Debian style duplicates
remove_dir /usr/lib/aarch64-linux-gnu
remove_dir /usr/lib/arm-linux-gnueabihf
remove_dir /usr/lib/i386-linux-gnu
remove_dir /usr/lib/x86_64-linux-gnu

remove_dir /usr/local

epm install --skip-installed libjpeg8
