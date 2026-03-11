#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

PRODUCT=eagle

# Autodesk_EAGLE_9.6.2_English_Linux_64bit.tar.gz
VERSION=$(basename "$TAR" | sed -E 's/^Autodesk_EAGLE_([0-9.]+)_.*/\1/')

erc -C opt/$PRODUCT unpack $TAR || fatal

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Engineering
license: Freeware
url: https://www.autodesk.com/products/eagle/
summary: EAGLE is electronic design automation (EDA) software that lets printed circuit board (PCB)
EOF

return_tar $PKGNAME.tar
