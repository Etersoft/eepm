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

fix_desktop_file $PRODUCTDIR/Lunacy $PRODUCT
fix_desktop_file $PRODUCTDIR/Assets/LunacyLogo.png $PRODUCT
install_file $PRODUCTDIR/Assets/LunacyLogo.png /usr/share/pixmaps/$PRODUCT.png
install_file ipfs://QmfZZUmUcShfXeNCbKxXXiX4Ds74Tj9yGPskBkwSnPWssn /usr/share/mime/packages/$PRODUCT.xml


