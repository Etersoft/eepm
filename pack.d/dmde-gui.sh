#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
PKGURL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$PKGURL" | sed -n 's|.*/dmde-\([0-9][0-9-]*\)-lin64-gui\.zip|\1|p' | sed 's|-|.|g')"
[ -n "$VERSION" ] || fatal "Can't get package version"
PKGNAME=$PRODUCT-$VERSION

erc -C opt/$PRODUCT unpack "$TAR" || fatal

install_file https://dmde.com/img/dmdeicon.svg /usr/share/icons/hicolor/scalable/apps/$PRODUCT.svg

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Name=DMDE
GenericName=Disk Editor and Data Recovery Software
Comment=DM Disk Editor and Data Recovery Software
Exec=$PRODUCT
Icon=$PRODUCT
Terminal=false
Type=Application
Categories=System;Filesystem;
Keywords=disk;editor;recovery;data;filesystem;
EOF

erc pack "$PKGNAME.tar" opt usr || fatal

cat <<EOF >"$PKGNAME.tar.eepm.yaml"
name: $PRODUCT
version: $VERSION
group: File tools
license: Proprietary
url: https://dmde.com/
summary: DMDE GUI data recovery tool
description: DMDE is a powerful tool for data searching, editing, and recovery on disks. It is able to recover directory structure and files even in some complex cases through the use of special algorithms when other software can't help.
EOF

return_tar "$PKGNAME.tar"
