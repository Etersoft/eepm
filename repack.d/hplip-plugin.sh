#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

subst '1iAutoReq:no' $SPEC
subst '1iAutoProv:no' $SPEC

subst "s|^License: unknown$|License: Proprietary|" $SPEC
subst "s|^Summary:.*|Summary: Binary plugin for HPs hplip printer driver library|" $SPEC
