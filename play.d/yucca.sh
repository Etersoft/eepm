#!/bin/sh

PKGNAME=yucca
SUPPORTEDARCHES="x86_64 armv7l aarch64"
VERSION="$2"
DESCRIPTION="Simple solution for video surveillance"
URL="https://yucca.app/"

. $(dirname $0)/common.sh

case $(epm print info -a) in
    x86_64)
        arch=amd64 ;;
    armv7l)
        arch=arm ;;
    aarch64)
        arch=arm64 ;;
    *)
        fatal "Unsupported arch $arch for $(epm print info -d)"
esac

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget --list --latest "https://docs.yucca.app/releases/" | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+')
fi

PKGURL="https://releases.yucca.app/v${VERSION}/yucca_${VERSION}_linux_${arch}.tar.gz"

install_pack_pkgurl $VERSION
