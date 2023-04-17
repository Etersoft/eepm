#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Graphics|" $SPEC
subst "s|^License:.*$|License: Proprietary|" $SPEC
subst "s|^URL:.*|URL: https://github.com/zerotier/ZeroTierOne|" $SPEC
subst "s|^Summary:.*|Summary: Panasonic Scanner Driver for Linux|" $SPEC


#subst '1iAutoReq:no' $SPEC
subst '1iAutoProv:no' $SPEC

