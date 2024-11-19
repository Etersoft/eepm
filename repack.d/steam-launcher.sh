#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=steam-launcher

. $(dirname $0)/common.sh

subst "s|.*/etc/apt.*||" $SPEC

remove_dir "/etc/apt"

set_autoreq 'yes'
