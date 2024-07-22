#!/bin/sh

PKGNAME=tsukimi
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='A Simple Third-party GTK4 Emby client'
URL="https://github.com/tsukinaha/tsukimi"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/tsukinaha/tsukimi/" "tsukimi-x86_64-linux-gnu.tar.gz")
else
    PKGURL="https://github.com/tsukinaha/tsukimi/releases/download/v$VERSION/tsukimi-x86_64-linux-gnu.tar.gz"
fi

install_pack_pkgurl
