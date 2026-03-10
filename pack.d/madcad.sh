#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
. $(dirname $0)/common.sh

# uimadcad_0.7_x86_64.tar.gz
BASENAME=$(basename $TAR .tar.gz)
VERSION=$(echo $BASENAME | sed -e 's|^uimadcad_||' | sed -e 's|_x86_64||')

erc --here unpack $TAR || fatal

cd linux*

mkdir -p opt/madcad
mkdir -p usr/share

# move nessesary files to opt
mv share/madcad opt/
mv share/ usr/
mv bin/madcad opt/madcad

# fix startup script 
subst 's|/share/madcad|/madcad|' opt/madcad/madcad

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Engineering
license: LGPL-3.0
url: https://madcad.netlify.app/
summary: MadCAD 3D CAD modeling tool
description: MadCAD is a 3D CAD modeling tool.
EOF

return_tar $PKGNAME.tar
