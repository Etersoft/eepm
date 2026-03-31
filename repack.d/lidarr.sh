#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# original deb depends on libchromaprint-tools, on ALT it's fpcalc
subst "s|libchromaprint-tools|fpcalc|" $SPEC
