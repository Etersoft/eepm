#!/bin/sh

PKGNAME=chromium-gost-stable
DESCRIPTION="Chromium with GOST support from the official site"

. $(dirname $0)/common.sh

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

if epm installed chromium-gost ; then
    fatal "Package chromium-gost is already installed from ALT repository."
fi

#arch=$($DISTRVENDOR --distro-arch)
#pkgtype=$($DISTRVENDOR -p)
arch=amd64
pkgtype=deb

PKG=$($EGET --list --latest https://github.com/deemru/chromium-gost/releases "$PKGNAME-*linux-$arch.$pkgtype") || fatal "Can't get package URL"

epm install "$PKG"
