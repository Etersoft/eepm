#!/bin/sh

PKGNAME=penpot-desktop
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Unofficial desktop application for Penpot"
URL="https://github.com/author-more/penpot-desktop"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        debarch=amd64
        ;;
    aarch64)
        debarch=arm64
        ;;
esac

case $(epm print info -p) in
    rpm)
        filename="$PKGNAME-$arch.rpm"
        oldfilename="$PKGNAME-$VERSION.$arch.rpm"
        ;;
    *)
        filename="$PKGNAME-$debarch.deb"
        oldfilename="${PKGNAME}_${VERSION}_${debarch}.deb"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url "$URL" "$filename")"
else
    # Upstream included the version in package names before 0.22.0.
    is_version_older "$VERSION" 0.22.0 && filename="$oldfilename"
    PKGURL="$URL/releases/download/v$VERSION/$filename"
fi

install_pkgurl
