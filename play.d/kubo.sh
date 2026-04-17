#!/bin/sh

BASEPKGNAME=kubo
SUPPORTEDARCHES="x86_64 x86 aarch64 armhf"
PRODUCTALT="'' beta"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Kubo - An IPFS implementation in Go from the official site"
URL="https://github.com/ipfs/kubo"

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

PKGURL=""
if [ "$VERSION" != "*" ] ; then
    URLVERSION="$VERSION"
    # if RELEASE is rc-suffix (e.g. rc1), append to version: 0.41.0 + rc1 -> v0.41.0-rc1
    case "$RELEASE" in
        rc*) URLVERSION="${VERSION}-${RELEASE}" ;;
    esac
    PKGURL="https://github.com/ipfs/kubo/releases/download/v${URLVERSION}/${BASEPKGNAME}_v${URLVERSION}_${file}"
    # validate; on miss fall back to scraping (e.g. stale app-versions)
    eget --check-url "$PKGURL" >/dev/null 2>&1 || PKGURL=""
fi

if [ -z "$PKGURL" ] ; then
    # beta:
    # v0.20.0-rc1_linux
    # kubo_v*-rc*_linux*.tar.gz

    # v0.20.0_linux
    # kubo_v*.[0-9]_linux*.tar.gz
    [ "$PKGNAME" = "$BASEPKGNAME" ] && GLOB="*.[0-9]_" || GLOB="*-rc*_"
    PKGURL="$(eget --list --latest https://github.com/ipfs/kubo/releases "${BASEPKGNAME}_v${GLOB}$file")"
fi

install_pack_pkgurl
