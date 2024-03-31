#!/bin/sh

PKGNAME=librewolf
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="LibreWolf - a custom version of Firefox, focused on privacy, security and freedom"
URL="https://librewolf.net/"

. $(dirname $0)/common.sh

arch=x86_64

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        # https://rpm.librewolf.net/pool/librewolf-124.0.1-1.fc38.x86_64.rpm
        PKGURL="https://rpm.librewolf.net/pool/librewolf-$VERSION-[0-9]*.$arch.rpm"
        ;;
    *)
        # https://deb.librewolf.net/pool/focal/librewolf-124.0.1-1.en-US.ubuntu20.x86_64.deb
        PKGURL="https://deb.librewolf.net/pool/focal/librewolf-$VERSION-[0-9]*.$arch.deb"
        ;;
esac

if ! is_glibc_enough 2.35 ; then
    # use deb package for old glibc
    PKGURL="https://deb.librewolf.net/pool/focal/librewolf-$VERSION-[0-9].$arch.deb"
fi

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

epm install $repack "$PKGURL"
