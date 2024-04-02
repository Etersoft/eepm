#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PKGNAME="eepm-i586-libcrypto7"
subst "s|^Name:.*|Name: $PKGNAME|" $SPEC

. $(dirname $0)/common.sh

# FIXME: can't generate 32 bit requires
#add_libs_requires
