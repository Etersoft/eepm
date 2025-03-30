#!/bin/sh

PKGNAME=myoffice-standard-home-edition
SKIPREPACK=1
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="MyOffice Standart Home Edition for Linux from the official site"
URL="https://myoffice.ru/products/standard-home-edition/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# /var/lib/dpkg/info/myoffice-standard-home-edition.postinst: line 62: xdg-desktop-menu: command not found
epm assure xdg-desktop-menu xdg-utils

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        PKGURL="https://preset.myoffice-app.ru/MyOfficeStandardHomeEdition.rpm"
        ;;
    *)
        PKGURL="https://preset.myoffice-app.ru/MyOfficeStandardHomeEdition.deb"
        ;;
esac

epm install "$PKGURL"
