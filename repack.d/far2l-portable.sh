#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=far2l
PRODUCTDIR=/opt/far2l-portable

. $(dirname $0)/common.sh

subst '1iAutoReq:no' $SPEC
subst '1iAutoProv:no' $SPEC

subst '1iConflicts: far2l' $SPEC

add_bin_cdexec_command

