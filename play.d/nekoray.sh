#!/bin/sh

PKGNAME=nekoray
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Qt based cross-platform GUI proxy configuration manager (backend: Xray / sing-box)"
URL="https://github.com/MatsuriDayo/nekoray"
. $(dirname $0)/common.sh

arch=x64
pkgtype=deb

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/MatsuriDayo/nekoray/" "nekoray-.$VERSION-debian-$arch.$pkgtype")
else
    PKGURL=$(get_github_version "https://github.com/MatsuriDayo/nekoray/" "nekoray-$VERSION.*-debian-$arch.$pkgtype")
fi

install_pkgurl
