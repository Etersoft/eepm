#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"

PKGNAME=amethyst-mod-manager

. $(dirname $0)/common.sh

stop_libs_requires
subst "s|^Name:.*|Name: $PKGNAME|" $SPEC
