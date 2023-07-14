#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

# Infowatch product Device

# remove kernel related script
rm -fv $BUILDROOT/opt/iw/dmagent/etc/initramfs-tools/hooks/iwdm
subst 's|"*/opt/iw/dmagent/etc/initramfs-tools/hooks/iwdm"*||' $SPEC

set_autoreq 'yes'
