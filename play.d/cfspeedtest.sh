#!/bin/sh

PKGNAME=cfspeedtest
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="cfspeedtest - unofficial CLI for speed.cloudflare.com"
URL="https://github.com/code-inflation/cfspeedtest"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
arch="$arch-unknown-linux-gnu"

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "cfspeedtest-$arch.tar.gz")
else
    PKGURL="https://github.com/code-inflation/cfspeedtest/releases/download/v$VERSION/cfspeedtest-$arch.tar.gz"
fi

install_pack_pkgurl
