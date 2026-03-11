#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

PRODUCT=openIDE

# openIDE-253.28294.334.2.tar.gz or openIDE-253.28294.334.1-eap.tar.gz
VERSION=$(basename "$TAR" | sed -E 's/^openIDE-([0-9.]+)(-eap)?.*\.tar\.gz$/\1/')

erc -C opt/$PRODUCT unpack $TAR || fatal

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Development/Tools
license: Apache-2.0
url: https://openide.ru/
summary: openIDE - Free IDE based on IntelliJ IDEA Community Edition
EOF

return_tar $PKGNAME.tar
