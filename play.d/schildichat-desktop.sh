#!/bin/sh

PKGNAME=schildichat-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Matrix client / Element Web / Desktop fork'
URL="https://schildi.chat/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

case $(epm print info -p) in
    rpm)
        mask="schildichat-desktop*x86_64.rpm"
        ;;
    deb)
        mask="schildichat-desktop*_amd64.deb"
        ;;
    *)
        mask="SchildiChat*.AppImage"
        ;;
esac

PKGURL="$(eget --list --latest https://github.com/SchildiChat/schildichat-desktop/releases "$mask")"

if [ $mask = 'SchildiChat*.AppImage' ]; then
    install_pack_pkgurl
else
    install_pkgurl
fi
