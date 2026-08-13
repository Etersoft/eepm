#!/bin/sh

PKGNAME=yandex-smart-home-control
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Desktop application for Yandex Smart Home control"
URL="https://github.com/onegamerstory/Desktop-Yandex.Home-App"

. $(dirname $0)/common.sh

case "$(epm print info -p)" in
    rpm)
        pkgformat=rpm
        ;;
    deb)
        pkgformat=deb
        ;;
    *)
        pkgformat=AppImage
        ;;
esac

PKGURL="$(get_github_url "$URL" "LIN_Yandex.Smart.Home.Control.Setup.v$VERSION.$pkgformat")"

install_pkgurl
