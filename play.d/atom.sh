#!/bin/sh

PKGNAME=atom-beta
SUPPORTEDARCHES="x86_64"
DESCRIPTION="The hackable text editor from the official site"


. $(dirname $0)/common.sh

#arch=$($DISTRVENDOR --distro-arch)
#pkgtype=$($DISTRVENDOR -p)
arch=amd64
pkgtype=deb

PKG=$(epm tool eget --list --latest https://github.com/atom/atom/releases/ "atom-$arch.$pkgtype") || fatal "Can't get package URL"

epm install "$PKG"
