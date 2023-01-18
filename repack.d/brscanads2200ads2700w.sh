#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

# Remove LIBJPEG version
subst '1i%filter_from_requires /LIBJPEG.*_6.2/d' $SPEC
