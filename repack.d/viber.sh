#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

mkdir -p $BUILDROOT/usr/bin/
ln -s /opt/viber/Viber $BUILDROOT/usr/bin/viber
ln -s /opt/viber/Viber $BUILDROOT/usr/bin/Viber
subst 's|%files|%files\n/usr/bin/viber\n/usr/bin/Viber|' $SPEC
