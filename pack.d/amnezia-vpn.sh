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

# Qt Installer Framework installer: extract the components without running it
# (the installer runs post_install.sh via sudo on the host)
mkdir -p opt/$APPNAME
erc -C opt/$APPNAME unpack "$TAR" || fatal
[ -x opt/$APPNAME/bin/$APPNAME ] || fatal "Can't find bin/$APPNAME in $TAR"

# remove maintainer scripts (repack.d replaces post_install.sh)
rm -f opt/$APPNAME/post_install.sh opt/$APPNAME/post_uninstall.sh

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
