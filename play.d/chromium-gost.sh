#!/bin/sh

# filename does not contain -stable, but package name with -stable
PKGNAME=chromium-gost-stable
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Chromium with GOST support from the official site"

. $(dirname $0)/common.sh

# TODO: use get_pkgvendor = "ALT Linux Team"
if epm installed chromium-gost ; then
    echo "Package chromium-gost is already installed from ALT repository."
    exit 0
fi

#arch=$($DISTRVENDOR --distro-arch)
#pkgtype=$($DISTRVENDOR -p)
arch=amd64
pkgtype=deb

PKG=$(epm tool eget --list --latest https://github.com/deemru/chromium-gost/releases "chromium-gost-*linux-$arch.$pkgtype") || fatal "Can't get package URL"

epm install "$PKG"
