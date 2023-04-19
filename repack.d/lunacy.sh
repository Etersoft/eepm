#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=lunacy
PRODUCTCUR=Lunacy
PRODUCTDIR=/opt/icons8/lunacy

. $(dirname $0)/common.sh

add_bin_link_command $PRODUCTCUR
add_bin_link_command $PRODUCT $PRODUCTCUR

fix_desktop_file
fix_desktop_file /opt/icons8/lunacy/Assets/LunacyLogo.png $PRODUCT.png
install_file /opt/icons8/lunacy/Assets/LunacyLogo.png /usr/share/pixmaps/$PRODUCT.png

subst '1iAutoProv:no' $SPEC
subst '1iAutoReq:yes,nomono,nomonolib' $SPEC

if [ "$(epm print info -s)" = "alt" ] ; then
    epm install --skip-installed liblttng-ust libX11 fontconfig zlib
fi
