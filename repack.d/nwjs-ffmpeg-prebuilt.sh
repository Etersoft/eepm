#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

add_conflicts ffmpeg-plugin-browser
add_provides ffmpeg-plugin-browser

add_libs_requires
