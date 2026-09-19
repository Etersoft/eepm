#!/bin/sh

PKGNAME=yandex-document
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Yandex 360 desktop office suite for editing documents and spreadsheets offline"
URL="https://360.yandex.ru/documents/desktop/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        PKGURL="https://cdn.docs.yandex.net/releases/public/latest/rpm/x64/yandex-document.rpm"
        ;;
    *)
        PKGURL="https://cdn.docs.yandex.net/releases/public/latest/debian/x64/yandex-document.deb"
        ;;
esac

install_pkgurl
