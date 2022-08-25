#!/bin/sh

PKGNAME=myoffice-standard-home-edition
SUPPORTEDARCHES="x86_64"
DESCRIPTION="MyOffice for Linux from the official site"

if [ "$1" = "--remove" ] ; then
    # Allow scripts: MyOffice reclaims their rpm package supports ALT
    epm remove --scripts $PKGNAME
    exit
fi


. $(dirname $0)/common.sh

arch=$($DISTRVENDOR --distro-arch)
pkgtype=$($DISTRVENDOR -p)

# https://preset.myoffice-app.ru/myoffice-standard-home-edition_2022.01-1.28.0.4_amd64
PKGMASK="$(epm print constructname $PKGNAME "*" $arch)"
PKG="$(epm tool eget --list --latest https://myoffice.ru/products/standard-home-edition/ $PKGMASK)" || fatal "Can't get package URL"

# /var/lib/dpkg/info/myoffice-standard-home-edition.postinst: line 62: xdg-desktop-menu: command not found
epm assure xdg-utils

epm --scripts install "$PKG"
