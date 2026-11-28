#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
UPKGNAME="$3"

. $(dirname $0)/common-java.sh

# bellsoft-java25-full -> liberica-jdk-25
major="$(echo "$UPKGNAME" | sed -E -n 's|^bellsoft-java([0-9]+)-full$|\1|p')"
[ -n "$major" ] || fatal "Unsupported package name $UPKGNAME"

PKGNAME="liberica-jdk-$major"
subst "s|^Name:.*|Name: $PKGNAME|" $SPEC

# use own dir to allow install together with bellsoft-java11-full
JVMDIR="/usr/lib/jvm/$PKGNAME"
move_dir /usr/lib/jvm/$UPKGNAME.x86_64 $JVMDIR

ignore_java_ffmpeg_requires

add_java_alternatives $JVMDIR ${major}000000

add_unirequires libX11.so.6 libXext.so.6 libXi.so.6 libXrender.so.1 libXtst.so.6 libasound.so.2 libfreetype.so.6
