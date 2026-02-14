#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

erc unpack "$TAR" || fatal

mkdir -p opt/$PRODUCT
mv qms_lib opt/$PRODUCT/qms-speedtest
chmod 755 opt/$PRODUCT/qms-speedtest

VERSION=$(opt/$PRODUCT/qms-speedtest --version 2>&1 | grep -oP '[0-9]+\.[0-9.]+' | head -1)
[ -n "$VERSION" ] || VERSION="1.0"

PKGNAME=$PRODUCT-$VERSION

mkdir -p usr/bin
ln -s /opt/$PRODUCT/qms-speedtest usr/bin/qms-speedtest

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Other
license: Proprietary
url: https://www.qms.ru/applications/linux
summary: QMS speedtest - internet connection speed and quality testing tool
description: Command-line tool for testing internet connection speed and quality from qms.ru.
EOF

erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar
