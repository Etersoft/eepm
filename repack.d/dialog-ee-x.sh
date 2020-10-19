#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

# https://bugzilla.altlinux.org/show_bug.cgi?id=39099
subst '1i%filter_from_requires /^.opt.Dialog$/d' $SPEC
