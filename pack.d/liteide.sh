#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

# liteidex38.3.linux64-qt5.5.1-system.tar.gz
VERSION=$(basename "$TAR" | sed -E 's/^liteidex([0-9.]+)\.linux.*/\1/')

erc -C opt/$PRODUCT unpack $TAR || fatal

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: LGPLv2
url: https://liteide.org/en/
summary: LiteIDE is a simple, open source, cross-platform Go IDE
EOF

return_tar $PKGNAME.tar
