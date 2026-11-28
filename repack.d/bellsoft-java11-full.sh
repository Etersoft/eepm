#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common-java.sh

ignore_java_ffmpeg_requires

add_java_alternatives /usr/lib/jvm/bellsoft-java11-full.x86_64 11000000

add_unirequires libX11.so.6 libXext.so.6 libXi.so.6 libXrender.so.1 libXtst.so.6 libasound.so.2 libfreetype.so.6
