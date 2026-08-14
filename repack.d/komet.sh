#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"
PRODUCT=komet
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# Komet bundles its JRE under /opt/komet, so host JVM libraries are not needed.
ignore_lib_requires "libjvm.so()(64bit)" "libjli.so()(64bit)" "libjava.so()(64bit)"

add_bin_link_command $PRODUCT $PRODUCTDIR/Komet
