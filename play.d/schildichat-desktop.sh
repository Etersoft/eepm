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
    #     mask="${PKGNAME}-.${VERSION}.x86_64.rpm"
    #     ;;
    deb)
        mask="${PKGNAME}-.${VERSION}_amd64.deb"
        ;;
    *)
        mask="SchildiChat-.${VERSION}.AppImage"
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/SchildiChat/schildichat-desktop/" "$mask")
else
    # need because get_github_version doesn't support ${VERSION} without a dot before VERSION in mask
    direct_mask="$(echo $mask | sed 's/\.//')"
    PKGURL="https://github.com/SchildiChat/schildichat-desktop/releases/download/v$VERSION/$direct_mask"
fi

if [ $mask = "SchildiChat-.${VERSION}.AppImage" ]; then
    install_pack_pkgurl
else
    install_pkgurl
fi
