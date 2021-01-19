#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=yandex-browser-beta
PRODUCTDIR=/opt/yandex/browser-beta
subst 's|%files|%files\n/usr/share/icons/hicolor/*x*/apps/*.png|' $SPEC

for i in 16 22 24 32 48 64 128 256 ; do
    mkdir -p $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/
    cp $BUILDROOT/$PRODUCTDIR/product_logo_${i}.png $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/$PRODUCT.png
done

rm -f $BUILDROOT/etc/cron.daily/$PRODUCT
subst "s|.*/etc/cron.daily/$PRODUCT.*||" $SPEC

# unsupported format
rm -f $BUILDROOT/usr/share/menu/$PRODUCT.menu
subst "s|.*/usr/share/menu/$PRODUCT.menu.*||" $SPEC

if ! grep -q '^"/usr/bin/yandex-browser"' $SPEC ; then
    subst 's|\(.*/usr/bin/yandex-browser.*\)|"/usr/bin/yandex-browser"\n\1|' $SPEC
fi

# missed in rpm package (ALT bug #39564)
[ -x $BUILDROOT/usr/bin/yandex-browser ] || ln -sv yandex-browser-beta $BUILDROOT/usr/bin/yandex-browser

