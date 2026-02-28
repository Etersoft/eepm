#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(echo "$URL" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' | head -n1)"
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION
APPNAME="CHITUBOX_Basic"

# Qt Installer Framework binary: extract with fakeroot
chmod +x "$TAR"
fakeroot "$TAR" --root "$PWD/install-root" --accept-licenses --no-size-checking --accept-messages --confirm-command install 2>/dev/null || fatal "Can't extract installer"

mkdir -p opt/$APPNAME
mv install-root/* opt/$APPNAME/

# remove installer metadata
rm -rf opt/$APPNAME/Uninstall* opt/$APPNAME/installer* opt/$APPNAME/components.xml opt/$APPNAME/network.xml opt/$APPNAME/InstallationLog.txt

install -d usr/bin
ln -s /opt/$APPNAME/$APPNAME.sh usr/bin/$PRODUCT

erc pack $PKGNAME.tar opt usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Graphics
license: Proprietary
url: https://www.chitubox.com/
summary: All-in-one SLA/DLP/LCD slicer for 3D printing
description: CHITUBOX Basic is a free 3D printing slicer for SLA/DLP/LCD printers.
EOF

return_tar $PKGNAME.tar
