#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=yandex-browser-beta
PRODUCTDIR=/opt/yandex/browser-beta

# needed alternatives
subst '1iProvides:webclient' $SPEC

subst "s|%files|%files\n/etc/alternatives/packages.d/$PRODUCT|" $SPEC
mkdir -p $BUILDROOT/etc/alternatives/packages.d/
cat <<EOF >$BUILDROOT/etc/alternatives/packages.d/$PRODUCT
/usr/bin/xbrowser	/usr/bin/$PRODUCT	55
/usr/bin/x-www-browser	/usr/bin/$PRODUCT	55
EOF

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

# replace embedded xdg tools
for EMBDIR in /opt/yandex/browser-beta/{xdg-mime,xdg-settings} ; do
    rm -v $BUILDROOT$EMBDIR
    ln -s /usr/bin/$(basename $EMBDIR) $BUILDROOT$EMBDIR
done

# install all requires packages before packing (the list have got with rpmreqs package | xargs echo)
epm install --skip-installed at-spi2-atk file gawk GConf glib2 grep libatk libat-spi2-core libcairo libcups libdbus libdrm libexpat libgbm libgdk-pixbuf libgio libgtk+3 libnspr libnss libpango \
            libX11 libxcb libXcomposite libXcursor libXdamage libXext libXfixes libXi libXrandr libXrender libXtst sed tar which xdg-utils xprop
