#!/bin/sh

PKGNAME=atom-beta
DESCRIPTION="The hackable text editor from the official site"


. $(dirname $0)/common.sh

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

#arch=$($DISTRVENDOR --distro-arch)
#pkgtype=$($DISTRVENDOR -p)
arch=amd64
pkgtype=deb

PKG=$($EGET --list --latest https://github.com/atom/atom/releases/ "atom-$arch.$pkgtype") || fatal "Can't get package URL"

epm install "$PKG"
