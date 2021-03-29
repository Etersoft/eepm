#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

# TODO: s/freetype/libfreetype/
# see https://bugzilla.altlinux.org/show_bug.cgi?id=38892

test -f /lib64/ld-linux-x86-64.so.2 && exit

# drop x86_64 req from 32 bit binary
sed -E -i -e "s@/lib64/ld-linux-x86-64.so.2@/lib/ld-linux.so.2\x0________@" $BUILDROOT/opt/zoom/libQt5Core.so.*

subst '1i%filter_from_requires /^mesa-dri-drivers(x86-32)/d' $SPEC
