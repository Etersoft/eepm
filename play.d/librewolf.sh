#!/bin/sh

PKGNAME=librewolf
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="LibreWolf - a custom version of Firefox, focused on privacy, security and freedom"
URL="https://librewolf.net/"
CODEBERG_RELEASES_URL="https://codeberg.org/librewolf/bsys6/releases"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"

if [ "$arch" = "aarch64" ]; then
    arch="arm64"
fi

pkgtype=$(epm print info -p)
pkgformat=deb
suffix=deb.deb
case $pkgtype in
    rpm)
        # use deb package for old glibc
        if is_glibc_enough 2.35 ; then
            pkgformat=rpm
            suffix=rpm.rpm
        fi
        ;;
esac

if [ "$VERSION" != "*" ] && [ -n "$RELEASE" ] && [ "$RELEASE" != "*" ] ; then
    VERSION="$VERSION-$RELEASE"
fi

PKGURL="$(eget --list --latest "$CODEBERG_RELEASES_URL" "librewolf-$VERSION-linux-$arch-$suffix")"

[ -n "$PKGURL" ] || fatal "Can't get LibreWolf $pkgformat package URL from $CODEBERG_RELEASES_URL"

install_pkgurl
