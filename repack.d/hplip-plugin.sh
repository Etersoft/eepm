#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

subst "s|^License: unknown$|License: Proprietary|" $SPEC
subst "s|^Summary:.*|Summary: Binary plugin for HPs hplip printer driver library|" $SPEC

add_requires hplip
