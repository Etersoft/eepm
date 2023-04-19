#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=spotify
LIBDIR=/opt

mkdir -p $BUILDROOT$LIBDIR/
mv $BUILDROOT/usr/share/$PRODUCT/ $BUILDROOT$LIBDIR/$PRODUCT/
subst "s|/usr/share/$PRODUCT|$LIBDIR/$PRODUCT|g" $SPEC

subst '1iAutoProv:no' $SPEC

# see https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=spotify
mkdir -p $BUILDROOT/usr/bin/
ln -sf $LIBDIR/$PRODUCT/$PRODUCT $BUILDROOT/usr/bin/$PRODUCT
mkdir -p $BUILDROOT/usr/share/applications/
ln -sf $LIBDIR/$PRODUCT/$PRODUCT.desktop $BUILDROOT/usr/share/applications/$PRODUCT.desktop
subst "s|%files|%files\n/usr/share/applications/$PRODUCT.desktop|" $SPEC
subst "s|%files|%files\n/usr/share/icons/hicolor/*/apps/*.png|" $SPEC

for i in 16 22 24 32 48 64 128 256 ; do
    mkdir -p $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/
    cp $BUILDROOT/$LIBDIR/$PRODUCT/icons/spotify-linux-$i.png $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/spotify-client.png
done

if [ "$(epm print info -s)" = "alt" ] ; then
    epm install --skip-installed libcurl4-gnutls
fi