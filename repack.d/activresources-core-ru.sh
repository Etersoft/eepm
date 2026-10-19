#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# /var/Promethean (mode 0777) is owned by activinspire
subst "s|^%dir \"/var/Promethean/*\"$||" $SPEC
subst "s|^%dir /var/Promethean/*$||" $SPEC
