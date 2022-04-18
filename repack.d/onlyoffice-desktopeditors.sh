#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

# TODO: required libreoffice-opensymbol-fonts
# $ rpm -qf /usr/lib64/LibreOffice/share/fonts/truetype/opens___.ttf
#LibreOffice-common-7.0.1.2-alt1.0.p9.x86_64

REQUIRES="fonts-ttf-liberation, fonts-ttf-dejavu"
subst "s|^\(Name: .*\)$|# Converted from original package requires\nRequires:$REQUIRES\n\1|g" $SPEC

# ignore embedded libs
for i in $BUILDROOT/opt/onlyoffice/desktopeditors/lib* ; do
    di=$(basename $i)
    echo "Filter out $di ..."
    subst "1i%filter_from_requires /^$di.*/d" $SPEC
done

epm assure patchelf || exit
for i in $BUILDROOT/opt/onlyoffice/desktopeditors/{libQt5Core.so.*,libicui18n.so,libicui18n.so.*,libicuuc.so,libicuuc.so.*} ; do
    a= patchelf --set-rpath '$ORIGIN/' $i || continue
done

for i in $BUILDROOT/opt/onlyoffice/desktopeditors/converter/*.so ; do
    a= patchelf --set-rpath '$ORIGIN/../' $i || continue
done

subst '1iAutoReq:no' $SPEC
subst '1iAutoProv:no' $SPEC

epm install --skip-installed bzlib fontconfig libalsa libcairo libcups libdrm libfreetype /usr/bin/perl zlib libXv glib2 libatk libcairo-gobject libEGL libgdk-pixbuf libgio libGL libgst-plugins1.0 libgstreamer1.0 libgtk+2 libgtk+3 libpango libpulseaudio libsqlite3 libX11 libxcb libxcb-render-util libXcomposite libXext libXfixes libxkbcommon libxkbcommon-x11 libXrender

