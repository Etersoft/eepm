#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCTDIR=/opt/onlyoffice

. $(dirname $0)/common.sh

# TODO: required libreoffice-opensymbol-fonts
# $ rpm -qf /usr/lib64/LibreOffice/share/fonts/truetype/opens___.ttf
#LibreOffice-common-7.0.1.2-alt1.0.p9.x86_64

add_requires fonts-ttf-liberation fonts-ttf-dejavu

# pack icons
iconname=onlyoffice-desktopeditors
for i in 16 22 24 32 48 64 128 256 ; do
    [ -r $BUILDROOT/$PRODUCTDIR/desktopeditors/asc-de-$i.png ] || continue
    mkdir -p $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/
    cp $BUILDROOT/$PRODUCTDIR/desktopeditors/asc-de-$i.png $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png
done
subst "s|%files|%files\n/usr/share/icons/hicolor/*x*/apps/$iconname.png|" $SPEC

fix_desktop_file /usr/bin/onlyoffice-desktopeditors

add_libs_requires
