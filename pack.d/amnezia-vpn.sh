#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(basename "$TAR" | sed -e 's|^AmneziaVPN_||' -e 's|_linux_.*||')"
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION
APPNAME=AmneziaVPN

epm assure fakeroot || fatal

# Qt Installer Framework binary: extract with fakeroot
chmod +x "$TAR"
a='' fakeroot "$TAR" --root "$PWD/install-root" --accept-licenses --no-size-checking --accept-messages --confirm-command install >/dev/null 2>&1 || fatal "Can't extract installer"

mkdir -p opt
mv install-root opt/$APPNAME || fatal

# remove installer metadata and maintainer scripts
cd opt/$APPNAME || fatal
rm -rf maintenancetool* installer.dat installerResources components.xml network.xml InstallationLog.txt post_install.sh post_uninstall.sh
cd - >/dev/null

erc pack $PKGNAME.tar opt || fatal

cat <<EOF2 >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Other
license: GPL-3.0
url: https://amnezia.org/
summary: AmneziaVPN client for self-hosted VPN
description: AmneziaVPN is a client for self-hosted VPN servers (AmneziaWG, WireGuard, OpenVPN, Xray, Shadowsocks and others).
EOF2

return_tar $PKGNAME.tar
