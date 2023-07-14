#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=steam-launcher

subst "s|.*/etc/apt.*||" $SPEC

set_autoreq 'yes'
