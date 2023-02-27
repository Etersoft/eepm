#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/onlyoffice

. $(dirname $0)/common.sh

# TODO: required libreoffice-opensymbol-fonts
# $ rpm -qf /usr/lib64/LibreOffice/share/fonts/truetype/opens___.ttf
#LibreOffice-common-7.0.1.2-alt1.0.p9.x86_64

REQUIRES="fonts-ttf-liberation, fonts-ttf-dejavu"
subst "s|^\(Name: .*\)$|# Converted from original package requires\nRequires:$REQUIRES\n\1|g" $SPEC

# ignore embedded libs
for i in $BUILDROOT/opt/onlyoffice/desktopeditors/lib* ; do
    di=$(basename $i)
    filter_from_requires $di
done

epm assure patchelf || exit
for i in $BUILDROOT/opt/onlyoffice/desktopeditors/{libQt5Core.so.*,libicui18n.so,libicui18n.so.*,libicuuc.so,libicuuc.so.*} ; do
    a= patchelf --set-rpath '$ORIGIN/' $i || continue
done

for i in $BUILDROOT/opt/onlyoffice/desktopeditors/converter/*.so ; do
    a= patchelf --set-rpath '$ORIGIN/:$ORIGIN/../' $i || continue
done

# pack icons
iconname=onlyoffice-desktopeditors
for i in 16 22 24 32 48 64 128 256 ; do
    [ -r $BUILDROOT/$PRODUCTDIR/desktopeditors/asc-de-$i.png ] || continue
    mkdir -p $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/
    cp $BUILDROOT/$PRODUCTDIR/desktopeditors/asc-de-$i.png $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png
done
subst "s|%files|%files\n/usr/share/icons/hicolor/*x*/apps/$iconname.png|" $SPEC


subst '1iAutoReq:no' $SPEC
subst '1iAutoProv:no' $SPEC

epm install --skip-installed bzlib fontconfig libalsa libcairo libcups libdrm libfreetype zlib libXv glib2 libatk libcairo-gobject libEGL libgdk-pixbuf libgio libGL libgst-plugins1.0 libgstreamer1.0 libgtk+2 libgtk+3 libpango libpulseaudio libsqlite3 libX11 libxcb libxcb-render-util libXcomposite libXext libXfixes libxkbcommon libxkbcommon-x11 libXrender

