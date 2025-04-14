#!/bin/sh

PKGNAME=tabby-terminal
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION='A terminal for a more modern age'
URL="https://github.com/Eugeny/tabby"

. $(dirname $0)/common.sh


arch="$(epm print info --debian-arch)"
case "$arch" in
    amd64)
        arch="x64" ;;
esac

case "$(epm print info -p)" in
    rpm)
        pkgtype=rpm ;;
    deb)
        pkgtype=deb ;;
    *)
        pkgtype=AppImage ;;
esac


if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/Eugeny/tabby/" "tabby-.$VERSION-linux-$arch.$pkgtype")
else
    PKGURL="https://github.com/Eugeny/tabby/releases/download/v$VERSION/tabby-$VERSION-linux-$arch.$pkgtype"
fi

install_pkgurl

