#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

# Infowatch product Device

# remove broken script
rm -fv $BUILDROOT/etc/init.d/*
subst 's|"*/etc/init.d/*"*||' $SPEC

set_autoreq 'yes'
