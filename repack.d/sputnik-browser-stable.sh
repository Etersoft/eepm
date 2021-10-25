#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=sputnik-browser

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

