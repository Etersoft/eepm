#!/bin/sh

PKGNAME=forticlient
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="FortiClient VPN-only from the official site"
URL="https://www.fortinet.com/support/product-downloads"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=forticlient-vpn
# TODO: get latest version
VERSION="7.4.3.1736"
arch="amd64"
PKGURL="https://filestore.fortinet.com/forticlient/downloads/forticlient_vpn_${VERSION}_$arch.deb"

install_pkgurl
