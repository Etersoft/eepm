#!/bin/sh

PKGNAME=myoffice-standard-home-edition
SUPPORTEDARCHES="x86_64"
DESCRIPTION="MyOffice Standart Home Edition for Linux from the official site"

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi


. $(dirname $0)/common.sh

pkgtype=$(epm print info -p)

# /var/lib/dpkg/info/myoffice-standard-home-edition.postinst: line 62: xdg-desktop-menu: command not found
epm assure xdg-desktop-menu xdg-utils

# https://preset.myoffice-app.ru/myoffice-standard-home-edition-2.3.0-x86_64.rpm
# https://preset.myoffice-app.ru/myoffice-standard-home-edition_2.3.0_amd64.deb
PKGMASK="$(epm print constructname $PKGNAME "*" "" "" "" "[-_]")"
PKG="$(epm tool eget --list --latest https://myoffice.ru/products/standard-home-edition/ "$PKGMASK")" || fatal "Can't get package URL"

epm install "$PKG"
