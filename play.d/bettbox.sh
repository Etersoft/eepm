#!/bin/sh

PKGNAME=Bettbox
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Bettbox - a Mihomo client for network debugging and rule-based traffic routing"
URL="https://github.com/appshubcc/Bettbox"

. $(dirname $0)/common.sh

# The repacked AppImage version ends in ~a; upstream release tags do not.
VERSION="${VERSION%~a}"

arch="$(epm print info -a)"

case "$arch" in
    x86_64)
        file="Bettbox-$VERSION-linux-amd64.AppImage"
        ;;
    aarch64)
        file="Bettbox-$VERSION-linux-arm64.deb"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "$file")
else
    PKGURL="$URL/releases/download/v$VERSION/$file"
fi

install_pkgurl
