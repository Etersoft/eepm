#!/bin/sh

PKGNAME=myoffice-standard-home-edition
SKIPREPACK=1
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="MyOffice Standart Home Edition for Linux from the official site"
URL="https://myoffice.ru/products/standard-home-edition/"

. $(dirname $0)/common.sh

pkgtype=$(epm print info -p)

# /var/lib/dpkg/info/myoffice-standard-home-edition.postinst: line 62: xdg-desktop-menu: command not found
epm assure xdg-desktop-menu xdg-utils

delim="-" 
if [ "$pkgtype" != "rpm" ] ; then
    delim="_"
    pkgtype="deb"
fi

# https://preset.myoffice-app.ru/myoffice-standard-home-edition-2.3.0-x86_64.rpm
# https://preset.myoffice-app.ru/myoffice-standard-home-edition_2.3.0_amd64.deb
PKGMASK="$(epm print constructname $PKGNAME "$VERSION" "" "$pkgtype" "" "$delim")"
if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest https://myoffice.ru/products/standard-home-edition/ "$PKGMASK")"
else
    PKGURL="https://preset.myoffice-app.ru/$PKGMASK"
fi

epm install "$PKGURL"
