#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=sputnik-browser
PRODUCTDIR=/opt/$PRODUCT

# needed alternatives
subst '1iProvides:webclient' $SPEC

subst "s|%files|%files\n/etc/alternatives/packages.d/$PRODUCT|" $SPEC
mkdir -p $BUILDROOT/etc/alternatives/packages.d/
cat <<EOF >$BUILDROOT/etc/alternatives/packages.d/$PRODUCT
/usr/bin/xbrowser	/usr/bin/$PRODUCT	55
/usr/bin/x-www-browser	/usr/bin/$PRODUCT	55
EOF

subst 's|%files|%files\n/usr/share/icons/hicolor/*x*/apps/*.png|' $SPEC

# Make relative symlink
mkdir -p $BUILDROOT/usr/bin
ln -s ../../opt/$PRODUCT/$PRODUCT $BUILDROOT/usr/bin/$PRODUCT-stable

ln -s $PRODUCT-stable $BUILDROOT/usr/bin/$PRODUCT
subst "s|%files|%files\n/usr/bin/$PRODUCT|" $SPEC

for i in 16 24 32 48 64 128 256 ; do
    mkdir -p $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/
    cp $BUILDROOT/opt/$PRODUCT/product_logo_$i.png $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/$PRODUCT.png
done

# replace embedded xdg tools
for EMBDIR in $PRODUCTDIR/{xdg-mime,xdg-settings} ; do
    [ -s $BUILDROOT$EMBDIR ] || continue
    rm -v $BUILDROOT$EMBDIR
    ln -s /usr/bin/$(basename $EMBDIR) $BUILDROOT$EMBDIR
done

# fix permission
chmod o-w -v $BUILDROOT$PRODUCTDIR/*

# install all requires packages before packing (the list have got with rpmreqs package | xargs echo)
epm install --skip-installed at-spi2-atk file gawk GConf glib2 grep libatk libat-spi2-core libcairo libcups libdbus libdrm libexpat libgbm libgdk-pixbuf libgio libgtk+3 libnspr libnss libpango \
            libX11 libxcb libXcomposite libXcursor libXdamage libXext libXfixes libXi libXrandr libXrender libXtst sed tar which xdg-utils xprop
