#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
. $(dirname $0)/common.sh

BROWSER_PKG="${PRODUCT%-codecs-ffmpeg-extra}"
add_requires "$BROWSER_PKG"
