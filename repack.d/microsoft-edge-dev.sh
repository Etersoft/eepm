#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=microsoft-edge-dev
PRODUCTDIR=/opt/microsoft/msedge-dev

subst 's|%files|%files\n/usr/share/icons/hicolor/*x*/apps/*.png|' $SPEC

# needed alternatives
subst '1iProvides:webclient' $SPEC

subst "s|%files|%files\n/etc/alternatives/packages.d/$PRODUCT|" $SPEC
mkdir -p $BUILDROOT/etc/alternatives/packages.d/
cat <<EOF >$BUILDROOT/etc/alternatives/packages.d/$PRODUCT
/usr/bin/xbrowser	/usr/bin/$PRODUCT	80
/usr/bin/x-www-browser	/usr/bin/$PRODUCT	80
EOF

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

if ! grep -q '^"/usr/bin/microsoft-edge"' $SPEC ; then
    subst 's|\(.*/usr/bin/microsoft-edge-dev.*\)|"/usr/bin/microsoft-edge"\n\1|' $SPEC
fi

# fix wrong interpreter
epm assure patchelf || exit
for i in $BUILDROOT/opt/microsoft/msedge-dev/libmip_*.so ; do
    [ "$(a= patchelf --print-interpreter $i)" = "/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2" ] && a= patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 $i
done
