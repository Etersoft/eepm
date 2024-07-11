#!/bin/sh

# filename does not contain -stable, but package name with -stable
PKGNAME=chromium-gost-stable
REPOPKGNAME=chromium-gost
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Chromium with GOST support from the official site"

. $(dirname $0)/common.sh

#arch=$(epm print info --distro-arch)
arch=amd64
pkgtype=deb

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/deemru/chromium-gost/" "chromium-gost-.$VERSION-linux-$arch.$pkgtype")
else
    PKGURL="https://github.com/deemru/chromium-gost/releases/download/$VERSION/chromium-gost-$VERSION-linux-$arch.$pkgtype"
fi

install_pkgurl
