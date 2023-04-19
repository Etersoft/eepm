#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

#PRODUCT=flashprint5
#PRODUCTDIR=/usr/lib/$PRODUCT

. $(dirname $0)/common.sh

move_file /usr/lib/libOCCTWrapper.so.1 /usr/lib64/libOCCTWrapper.so.1

if [ "$(epm print info -s)" = "alt" ] ; then
    epm install --skip-installed libGL libGLU libqt5-core libqt5-gui libqt5-network libqt5-opengl libqt5-widgets libudev1
fi

