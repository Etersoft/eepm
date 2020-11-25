#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=microsoft-edge-dev
PRODUCTDIR=/opt/microsoft/msedge-dev
subst 's|%files|%files\n/usr/share/icons/hicolor/*x*/apps/*.png|' $SPEC

for i in 16 22 24 32 48 64 128 256 ; do
    mkdir -p $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/
    cp $BUILDROOT/$PRODUCTDIR/product_logo_${i}_dev.png $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/$PRODUCT.png
done

rm -f $BUILDROOT/etc/cron.daily/$PRODUCT
subst "s|.*/etc/cron.daily/$PRODUCT.*||" $SPEC

# unsupported format
rm -f $BUILDROOT/usr/share/menu/microsoft-edge-dev.menu
subst "s|.*/usr/share/menu/microsoft-edge-dev.menu.*||" $SPEC

[ -e $BUILDROOT/usr/bin/microsoft-edge ] || ln -s $PRODUCT $BUILDROOT/usr/bin/microsoft-edge
