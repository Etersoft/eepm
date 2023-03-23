#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=far2l
PRODUCTDIR=/opt/far2l-portable

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: File tools|" $SPEC
#subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: https://github.com/elfmz/far2l|" $SPEC
subst "s|^Summary:.*|Summary: Linux port of FAR v2|" $SPEC


subst '1iAutoReq:no' $SPEC
subst '1iAutoProv:no' $SPEC

subst '1iConflicts: far2l' $SPEC

add_bin_cdexec_command

