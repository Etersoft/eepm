#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

. $(dirname $0)/common.sh

subst "s|User=headscale|User=root|" $BUILDROOT/usr/lib/systemd/system/headscale.service
subst "s|Group=headscale|Group=root|" $BUILDROOT/usr/lib/systemd/system/headscale.service

add_libs_requires
