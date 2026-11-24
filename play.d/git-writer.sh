#!/bin/sh

PKGNAME=gitwriter
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Git Writer - a Git-backed Markdown note-taking app"
URL="https://github.com/jotalac/git-writer"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
[ "$arch" = "aarch64" ] && arch=arm64

pkgtype="$(epm print info -p)"
[ "$pkgtype" = "rpm" ] || pkgtype=deb

asset="GitWriter-$VERSION-linux-$arch.$pkgtype"
if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url "$URL" "$asset")"
else
    PKGURL="$URL/releases/download/$VERSION/$asset"
fi

install_pkgurl
