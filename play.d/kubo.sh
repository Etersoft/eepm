#!/bin/sh

BASEPKGNAME=kubo
SUPPORTEDARCHES="x86_64 x86 aarch64 armhf"
PRODUCTALT="'' beta"
VERSION="$2"
DESCRIPTION="Kubo - An IPFS implementation in Go from the official site"
URL="https://github.com/ipfs/kubo"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    # beta:
    # v0.20.0-rc1_linux
    # kubo_v*-rc*_linux*.tar.gz

    # v0.20.0_linux
    # kubo_v*.[0-9]_linux*.tar.gz
    [ "$PKGNAME" = "$BASEPKGNAME" ] && VERSION="*.[0-9]_" || VERSION="*-rc*_"
fi

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        file="linux-amd64.tar.gz"
        ;;
    armhf)
        file="linux-arm.tar.gz"
        ;;
    x86)
        file="linux-386.tar.gz"
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac


PKGURL="$(eget --list --latest https://github.com/ipfs/kubo/releases "${BASEPKGNAME}_v$VERSION$file")"
epm pack --install $PKGNAME "$PKGURL"
