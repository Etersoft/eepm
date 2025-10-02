#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

erc $TAR || fatal

PRODUCTFOLDER="$(basename $TAR .tar.xz)"
VERSION=$(echo $PRODUCTFOLDER  | sed -e 's|RenameMyTVSeries-||' | sed -e 's|-GTK-Linux-x64-static-ffmpeg||')
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

mkdir -p usr/bin
mkdir -p usr/share/applications
mkdir -p usr/share/fonts/TTF

mv $PRODUCTFOLDER/RenameMyTVSeries usr/bin/RenameMyTVSeries

for size in 16 32 64 128 256 512; do
    mkdir -p usr/share/icons/hicolor/${size}x${size}/apps
    mv "$PRODUCTFOLDER/icons/${size}x${size}.png" \
        "usr/share/icons/hicolor/${size}x${size}/apps/renamemytvseries.png"
done

mv $PRODUCTFOLDER/RenameMyTVSeries.desktop "usr/share/applications/RenameMyTVSeries.desktop"

mv "$PRODUCTFOLDER/rmtv.ttf" "usr/share/fonts/TTF/rmtv.ttf"

subst "s|Icon=.*|Icon=renamemytvseries|" "usr/share/applications/RenameMyTVSeries.desktop"
subst '/^NoDisplay=true$/d' "usr/share/applications/RenameMyTVSeries.desktop"

erc pack $PKGNAME.tar usr

return_tar $PKGNAME.tar
