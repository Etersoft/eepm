#!/bin/sh
PKGNAME=localsend
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="An open-source cross-platform alternative to AirDrop"
URL="https://localsend.org/"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        arch=x86-64
        ;;
    aarch64)
        arch=arm-64
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

# https://github.com/localsend/localsend/releases/download/v1.17.0/LocalSend-1.17.0-linux-arm-64.deb
# https://github.com/localsend/localsend/releases/download/v1.17.0/LocalSend-1.17.0-linux-x86-64.deb

if [ "$VERSION" = "*" ] ; then 
    PKGURL="$(get_github_url https://github.com/localsend/localsend/ "LocalSend-${VERSION}-linux-${arch}.deb")"
else
    PKGURL="https://github.com/localsend/localsend/releases/download/v${VERSION}/LocalSend-${VERSION}-linux-$arch.deb"
fi

install_pkgurl
