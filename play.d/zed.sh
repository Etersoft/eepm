#!/bin/sh
PKGNAME=zed
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="High-performance, multiplayer code editor from the creators of Atom and Tree-sitter"
URL="https://zed.dev/"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        arch=x86_64
        ;;
    aarch64)
        arch=aarch64
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
	VERSION="$(eget -O- https://api.github.com/repos/zed-industries/zed/releases/latest | grep -oP '"tag_name": "\K(.*?)(?=")' | sed 's/v//g')"
fi

PKGURL="https://github.com/zed-industries/zed/releases/download/v$VERSION/zed-linux-$arch.tar.gz"

install_pack_pkgurl $VERSION
