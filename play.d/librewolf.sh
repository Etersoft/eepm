#!/bin/sh

PKGNAME=librewolf
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="LibreWolf - a custom version of Firefox, focused on privacy, security and freedom"
URL="https://librewolf.net/"

. $(dirname $0)/common.sh

arch=x86_64


if [ "$(epm print info -a)" = "aarch64" ]; then
    arch="arm64"
fi

if [ "$VERSION" = "*" ] ; then
    # Get latest version from vendor
    VERSION=$(eget --list --latest https://repo.librewolf.net/pool/ | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?')
fi

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        # https://repo.librewolf.net/pool/librewolf-132.0-1-linux-x86_64-rpm.rpm
        PKGURL="https://repo.librewolf.net/pool/librewolf-$VERSION-[0-9]*-linux-$arch-rpm.rpm"
        ;;
    *)
        # https://repo.librewolf.net/pool/librewolf-132.0-1-linux-x86_64-deb.deb
        PKGURL="https://repo.librewolf.net/pool/librewolf-$VERSION-[0-9]*-linux-$arch-deb.deb"
        ;;
esac

if ! is_glibc_enough 2.35 ; then
    # use deb package for old glibc
    PKGURL="https://repo.librewolf.net/pool/librewolf-$VERSION-[0-9]*-linux-$arch-deb.deb"
fi

install_pkgurl
