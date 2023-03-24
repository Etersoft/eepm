#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=jetbrains-toolbox
PRODUCTCUR=jetbrains-toolbox
PRODUCTDIR=/opt/$PRODUCTCUR

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Development/C|" $SPEC
#subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: https://www.jetbrains.com/ru-ru/toolbox-app/|" $SPEC
subst "s|^Summary:.*|Summary: JetBrains Toolbox App|" $SPEC

#move_to_opt "/$PRODUCT-*"
#add_bin_link_command $PRODUCT

#subst '1iAutoProv:no' $SPEC
# ldd: ERROR: /tmp/jetbrains-toolbox-1.25.12627/jetbrains-toolbox: failed to find the program interpreter
#subst 's|^AutoReq:.*|AutoReq:no|' $SPEC

exit
