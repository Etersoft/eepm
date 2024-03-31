#!/bin/sh

PKGNAME=k3s
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION="K3s - Lightweight Kubernetes from the official site"
URL="https://k3s.io"

. $(dirname $0)/common.sh


arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        file="k3s"
        ;;
    armhf)
        file="k3s-armhf"
        ;;
    aarch64)
        file="k3s-arm64"
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    # TODO: get latest version from somewhere?
    PKGURL="$(eget --list --latest https://github.com/k3s-io/k3s/releases "$file")"
else
    PKGURL="https://github.com/k3s-io/k3s/releases/download/v$VERSION+k3s1/$file"
fi

VERSION="$(echo "$PKGURL" | sed -e 's|.*download/v||' -e 's|%2Bk3s1.*||' -e 's|+k3s1.*||' -e 's|-.*||')"

install_pack_pkgurl $VERSION
