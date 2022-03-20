#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=brave-browser
PRODUCTCUR=brave-browser-nightly
PRODUCTDIR=/opt/brave.com/brave-nightly

# needed alternatives
subst '1iProvides:webclient' $SPEC

subst "s|%files|%files\n/etc/alternatives/packages.d/$PRODUCT|" $SPEC
mkdir -p $BUILDROOT/etc/alternatives/packages.d/
cat <<EOF >$BUILDROOT/etc/alternatives/packages.d/$PRODUCT
/usr/bin/xbrowser	/usr/bin/$PRODUCT	80
/usr/bin/x-www-browser	/usr/bin/$PRODUCT	80
EOF


# short command for run
ln -s $PRODUCTCUR $BUILDROOT/usr/bin/$PRODUCT
#subst "s|%files|%files\n/usr/bin/$PRODUCT|" $SPEC

# fix main link
rm -v $BUILDROOT/usr/bin/$PRODUCTCUR
ln -s $PRODUCTDIR/$PRODUCTCUR $BUILDROOT/usr/bin/$PRODUCTCUR

rm -v $BUILDROOT$PRODUCTDIR/$PRODUCT
ln -s $PRODUCTCUR $BUILDROOT$PRODUCTDIR/$PRODUCT


for i in 16 24 32 48 64 128 256 ; do
    [ -r $BUILDROOT/$PRODUCTDIR/product_logo_${i}_nightly.png ] || continue
    mkdir -p $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/
    cp $BUILDROOT/$PRODUCTDIR/product_logo_${i}_nightly.png $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/$PRODUCTCUR.png
done
subst 's|%files|%files\n/usr/share/icons/hicolor/*x*/apps/*.png|' $SPEC


if [ -r $BUILDROOT/etc/cron.daily/$PRODUCTCUR ] ; then
    rm -f $BUILDROOT/etc/cron.daily/$PRODUCTCUR
    subst 's|.*/etc/cron.daily/.*||' $SPEC
fi


# replace embedded xdg tools
for EMBDIR in $PRODUCTDIR/{xdg-mime,xdg-settings} ; do
    [ -s $BUILDROOT$EMBDIR ] || continue
    rm -v $BUILDROOT$EMBDIR
    ln -s /usr/bin/$(basename $EMBDIR) $BUILDROOT$EMBDIR
done

# install all requires packages before packing (the list have got with rpmreqs package | xargs echo)
epm install --skip-installed at-spi2-atk file gawk GConf glib2 grep libatk libat-spi2-core libcairo libcups libdbus libdrm libexpat libgbm libgdk-pixbuf libgio libgtk+3 libnspr libnss libpango \
            libX11 libxcb libXcomposite libXcursor libXdamage libXext libXfixes libXi libXrandr libXrender libXtst sed tar which xdg-utils xprop
