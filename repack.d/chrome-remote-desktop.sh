#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PKGNAME=chrome-remote-desktop

rm -f $BUILDROOT/etc/cron.daily/$PKGNAME
subst 's|.*/etc/cron.daily/$PKGNAME.*||' $SPEC

