#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# bundled FFmpeg plugins link against all libavcodec/libavformat versions (54-61)
# only one will be used at runtime depending on system ffmpeg version
ignore_lib_requires 'libavcodec.*'
ignore_lib_requires 'libavformat.*'

chmod +x $BUILDROOT/opt/pdfsam-basic/runtime/bin/java

