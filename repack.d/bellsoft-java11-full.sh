#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# JavaFX media links against multiple ffmpeg versions (54-59), none available in Sisyphus
ignore_lib_requires 'libavcodec.*' 'libavformat.*' 'libavcodec-ffmpeg.*' 'libavformat-ffmpeg.*'

add_unirequires libX11.so.6 libXext.so.6 libXi.so.6 libXrender.so.1 libXtst.so.6 libasound.so.2 libfreetype.so.6
