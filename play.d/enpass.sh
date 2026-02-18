#!/bin/sh

PKGNAME=enpass
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="A multiplatform password manager"
URL=" http://enpass.io/ "

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKG_INDEX_URL="https://apt.enpass.io/dists/stable/main/binary-amd64/Packages"

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -O- "$PKG_INDEX_URL" | grep '^Version:' | head -n1 | cut -d' ' -f2)
fi


PKGURL="https://apt.enpass.io/pool/main/e/enpass/enpass_${VERSION}_amd64.deb"

install_pkgurl
