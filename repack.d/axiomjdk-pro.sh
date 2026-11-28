#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
UPKGNAME="$3"

. $(dirname $0)/common-java.sh

# axiomjdk-java25-pro-full -> axiomjdk-pro-25
major="$(echo "$UPKGNAME" | sed -E -n 's|^axiomjdk-java([0-9]+)-pro-full$|\1|p')"
[ -n "$major" ] || fatal "Unsupported package name $UPKGNAME"

subst "s|^Name:.*|Name: axiomjdk-pro-$major|" $SPEC

ignore_java_ffmpeg_requires

add_java_alternatives /usr/lib/jvm/$UPKGNAME.x86_64 ${major}000000

add_unirequires libX11.so.6 libXext.so.6 libXi.so.6 libXrender.so.1 libXtst.so.6 libasound.so.2 libfreetype.so.6
