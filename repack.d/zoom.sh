#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

test -f /lib64/ld-linux-x86-64.so.2 && exit

# drop x86_64 req from 32 bit binary
sed -E -i -e "s@/lib64/ld-linux-x86-64.so.2@/lib/ld-linux.so.2\x0________@" $BUILDROOT/opt/zoom/libQt5Core.so.*

