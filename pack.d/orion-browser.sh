#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

erc --here unpack "$TAR"

# the download is a flatpak bundle; extract it via ostree (erc handles flatpak without flatpak installed)
erc oriongtk.$VERSION.flatpak

ORIONDIR=$(ls -d oriongtk.*/ | head -1)

mkdir -p usr/lib64 usr/bin usr/share/applications usr/share/icons usr/share/metainfo

# only the orion-specific libs
cp "$ORIONDIR/lib64/liborion_common.so" usr/lib64/
cp "$ORIONDIR/lib64/liborion_core.so" usr/lib64/
cp "$ORIONDIR/lib64/liborion_sync.so" usr/lib64/

# the browser binary
cp "$ORIONDIR/bin/oriongtk" usr/bin/oriongtk
chmod 755 usr/bin/oriongtk

# desktop entry, icons and metainfo
cp "$ORIONDIR/share/applications/com.kagi.OrionGtk.desktop" usr/share/applications/
cp -a "$ORIONDIR/share/icons/hicolor" usr/share/icons/
cp "$ORIONDIR/share/metainfo/com.kagi.OrionGtk.metainfo.xml" usr/share/metainfo/

PKGNAME=$PRODUCT-$VERSION.tar
erc pack $PKGNAME usr

cat <<EOF >$PKGNAME.eepm.yaml
name: $PRODUCT
version: $VERSION
group: Networking/WWW
license: Commercial
url: https://orionbrowser.com/download/
summary: Orion web browser by Kagi
description: Orion is a WebKitGTK-based web browser by Kagi with built-in tracker blocking and privacy features.
EOF

return_tar $PKGNAME
