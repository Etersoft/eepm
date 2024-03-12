#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTCUR=wing-personal

. $(dirname $0)/common.sh

move_to_opt
subst "s|/usr/lib/$PRODUCT|$PRODUCTDIR|" $BUILDROOT$PRODUCTDIR/$PRODUCTCUR

rm -v ./usr/bin/$PRODUCT
add_bin_link_command $PRODUCT $PRODUCTDIR/$PRODUCTCUR

add_libs_requires


for size in 16 32 48 64 128
do
    install_file $PRODUCTDIR/resources/wing$size.png //usr/share/icons/hicolor/${size}x${size}/apps/$PRODUCT.png
done

install_file $PRODUCTDIR/resources/linux/desktop/wing-personal10.desktop /usr/share/applications/$PRODUCT.desktop
install_file $PRODUCTDIR/resources/linux/desktop/wing-personal10.xml /usr/share/mime/packages/$PRODUCT.xml
