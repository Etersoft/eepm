#!/bin/sh

PKGNAME=tsukimi
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='A Simple Third-party GTK4 Emby client'
URL="https://github.com/tsukinaha/tsukimi"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/tsukinaha/tsukimi/" "tsukimi-$arch-linux.tar.gz")
else
    PKGURL="https://github.com/tsukinaha/tsukimi/releases/download/v$VERSION/tsukimi-$arch-linux.tar.gz"
fi

install_pack_pkgurl
