#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=lunacy
PRODUCTCUR=Lunacy
PRODUCTDIR=/opt/icons8/lunacy

[ -d ".$PRODUCTDIR" ] || PRODUCTDIR=/opt/lunacy

. $(dirname $0)/common.sh

add_bin_link_command $PRODUCTCUR
add_bin_link_command $PRODUCT $PRODUCTCUR

fix_desktop_file $PRODUCTCUR/Lunacy $PRODUCT
fix_desktop_file $PRODUCTCUR/Assets/LunacyLogo.png $PRODUCT
install_file $PRODUCTCUR/Assets/LunacyLogo.png /usr/share/pixmaps/$PRODUCT.png

add_libs_requires

