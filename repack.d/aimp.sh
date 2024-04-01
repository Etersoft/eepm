#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PRODUCT=aimp
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

add_requires '/usr/bin/wine'
add_requires '/bin/sh'

add_bin_link_command $PRODUCT $PRODUCTDIR/aimp.bash
subst "s|/usr/bin/sh|/bin/sh|" $BUILDROOT$PRODUCTDIR/aimp.bash

install_file /opt/aimp/aimp.desktop /usr/share/applications/aimp.desktop

fix_desktop_file /opt/aimp/aimp.bash $PRODUCT
