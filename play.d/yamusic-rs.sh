#!/bin/sh

PKGNAME=yamusic-rs
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Unofficial Yandex Music client written in Rust"
URL="https://github.com/SpolzerMod/yamusic-rs"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"
if [ "$pkgtype" = "rpm" ] ; then
    arch="$(epm print info -a)"
    filename="${PKGNAME}-${VERSION}-${RELEASE}.$arch.rpm"
elif [ "$pkgtype" = "deb" ] ; then
    arch="$(epm print info --debian-arch)"
    filename="${PKGNAME}_${VERSION}-${RELEASE}_$arch.deb"
else
    fatal "$(epm print info -e) is not supported (package type is $pkgtype)"
fi

if [ "$VERSION" != "*" ] && [ "$RELEASE" != "*" ] ; then
    PKGURL="$URL/releases/download/v$VERSION/$filename"
else
    PKGURL=$(get_github_url "$URL" "$filename")
fi

install_pkgurl
