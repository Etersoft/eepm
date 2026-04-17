#!/bin/sh

PKGNAME=adbmanager
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="ADB Manager - GUI tool for managing Android devices via ADB (freeze/unfreeze, remove bloatware)"
URL="https://github.com/AKotov-dev/adbmanager"

. $(dirname $0)/common.sh

case $(epm print info -p) in
    rpm)
        mask="${PKGNAME}-${VERSION}-*.x86_64.rpm"
        ;;
    *)
        mask="${PKGNAME}_${VERSION}-*_amd64.deb"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/AKotov-dev/adbmanager" "$mask")
else
    PKGURL="https://github.com/AKotov-dev/adbmanager/releases/download/v${VERSION}/$mask"
fi

install_pkgurl
