#!/bin/sh

# filename does not contain -stable, but package name with -stable
PKGNAME=chromium-gost-stable
REPOPKGNAME=chromium-gost
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Chromium with GOST support from the official site"

. $(dirname $0)/common.sh

#arch=$(epm print info --distro-arch)
#pkgtype=$(epm print info -p)
arch=amd64
pkgtype=deb

PKGURL=$(eget --list --latest https://github.com/deemru/chromium-gost/releases "chromium-gost-$VERSION-linux-$arch.$pkgtype") || fatal "Can't get package URL"

epm install "$PKGURL"
