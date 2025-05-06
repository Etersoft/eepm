#!/bin/sh

PKGNAME=schildichat-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Matrix client / Element Web / Desktop fork'
URL="https://schildi.chat/"

. $(dirname $0)/common.sh

pkgtype="$(epm print info -p)"

case $pkgtype in
    # rpm)
    #     mask="${PKGNAME}-${VERSION}.x86_64.rpm"
    #     ;;
    deb)
        mask="${PKGNAME}-${VERSION}_amd64.deb"
        ;;
    *)
        mask="SchildiChat-${VERSION}.AppImage"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/SchildiChat/schildichat-desktop/" "$mask")
else
    PKGURL="https://github.com/SchildiChat/schildichat-desktop/releases/download/v$VERSION/$mask"
fi

if [ $mask = "SchildiChat-${VERSION}.AppImage" ]; then
    install_pack_pkgurl
else
    install_pkgurl
fi
