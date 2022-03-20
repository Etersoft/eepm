#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=webex

# drop external requires
subst '1i%filter_from_requires /^libutil.so.*/d' $SPEC
