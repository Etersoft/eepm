#!/bin/sh

PKGNAME=librewolf
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="LibreWolf - a custom version of Firefox, focused on privacy, security and freedom"

. $(dirname $0)/common.sh

arch=x86_64

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        PKG="https://rpm.librewolf.net/pool/librewolf$VERSION.rpm"
        ;;
    deb)
        PKG="https://deb.librewolf.net/pool/focal/librewolf-$VERSION$arch.deb"
        ;;
    *)
        fatal "Package target $pkgtype is not supported yet"
        ;;
esac

if ! is_glibc_enough 2.35 ; then
    PKG="https://deb.librewolf.net/pool/focal/librewolf-$VERSION$arch.deb"
fi

epm install "$PKG"
