#!/bin/sh

DESCRIPTION="Kubo - An IPFS implementation in Go from the official site"
SUPPORTEDARCHES="x86_64 x86 aarch64 armhf"

BASEPKGNAME=kubo
PRODUCTALT="stable beta"

# kubo or kubo-beta
if [ "$2" = "beta" ] || epm installed $BASEPKGNAME-beta ; then
    PKGNAME=$BASEPKGNAME-beta
    # v0.20.0-rc1_linux
    # kubo_v*-rc*_linux*.tar.gz
    version="*-rc*_"
else
    PKGNAME=$BASEPKGNAME
    # v0.20.0_linux
    # kubo_v*.[0-9]_linux*.tar.gz
    version="*.[0-9]_"
fi

. $(dirname $0)/common.sh

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


PKGURL="$(eget --list --latest https://github.com/ipfs/kubo/releases ${BASEPKGNAME}_v$version$file)"
epm pack --install $PKGNAME "$PKGURL"
