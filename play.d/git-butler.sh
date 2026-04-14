#!/bin/sh

PKGNAME=git-butler
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="GitButler - Git client for modern workflows (branches, undo, AI)"
URL="https://gitbutler.com/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] || ! echo "$VERSION" | grep -q '~' ; then
    # Get version and build number from AUR PKGBUILD
    pkgbuild=$(eget -q -O- "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=gitbutler-bin")
    ver=$(echo "$pkgbuild" | grep -oP '^pkgver=\K.*')
    build=$(echo "$pkgbuild" | grep -oP '^_pkgvernum=\K.*')
    [ -n "$ver" ] && [ -n "$build" ] || fatal "Can't get version"
    VERSION="${ver}~${build}"
fi

# VERSION format: 0.19.7~2956
ver=$(echo "$VERSION" | cut -d~ -f1)
build=$(echo "$VERSION" | cut -d~ -f2)

PKGURL="https://releases.gitbutler.com/releases/release/${ver}-${build}/linux/x86_64/GitButler_${ver}_amd64.deb"

# pass full version with build number to repack
export EPM_REPACK_VERSION="$VERSION"
install_pkgurl
