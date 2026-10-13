#!/bin/sh

PKGNAME=session-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Session - private messenger with end-to-end encryption from the official site"
URL="https://github.com/session-foundation/session-desktop"

. $(dirname $0)/common.sh

case $(epm print info -p) in
    rpm)
        mask="$PKGNAME-linux-x86_64-$VERSION.rpm"
        ;;
    *)
        mask="$PKGNAME-linux-amd64-$VERSION.deb"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url "$URL" "$mask")"
else
    PKGURL="$URL/releases/download/v$VERSION/$mask"
fi

install_pkgurl
