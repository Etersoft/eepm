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
	PKGURL=$(get_github_version "https://github.com/zed-industries/zed/" "zed-linux-$arch.tar.gz") 
else 
	PKGURL="https://github.com/zed-industries/zed/releases/download/v$VERSION/zed-linux-$arch.tar.gz" 
fi

install_pack_pkgurl
