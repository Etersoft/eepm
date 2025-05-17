#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
#VERSION="$3"

. $(dirname $0)/common.sh

# blender-$pkgver-linux-x64
PKGNAME="$(basename $TAR | sed -e "s|-linux.*||")"

mkdir -p opt/
erc unpack $TAR
mv $PRODUCT* opt/$PRODUCT

mv_as()
{
    local tdir="$(dirname "$2")"
    mkdir -p ".$tdir"
    mv opt/$PRODUCT/"$1" ."$2"
}

cat <<EOF >x-blender.xml
<?xml version="1.0" encoding="utf-8"?>
<mime-type xmlns="http://www.freedesktop.org/standards/shared-mime-info" type="application/x-blender">
  <!--Created automatically by update-mime-database. DO NOT EDIT!-->
  <comment>Blender scene</comment>
  <glob pattern="*.blend"/>
</mime-type>
EOF

mv_as blender-symbolic.svg "/usr/share/icons/hicolor/symbolic/apps/blender-symbolic.svg"
mv_as blender.svg "/usr/share/icons/hicolor/scalable/apps/blender.svg"
mv_as blender.desktop "/usr/share/applications/blender.desktop"
mv_as x-blender.xml "/usr/share/mime/application/x-blender.xml"

erc pack $PKGNAME.tar opt usr

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Graphics
license: GPLv2
url: https://blender.org
summary: A fully integrated 3D graphics creation suite
description: A fully integrated 3D graphics creation suite
EOF

return_tar $PKGNAME.tar
