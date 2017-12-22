#!/bin/sh -x

# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

REQUIRES="mono-full,libgtk-sharp2"
subst "s|^\(Name: .*\)$|# Converted from original package requires\nRequires:$REQUIRES\n\1|g" $SPEC
