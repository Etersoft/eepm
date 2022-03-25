#!/bin/sh

PKGNAME=onlyoffice-desktopeditors
DESCRIPTION="ONLYOFFICE for Linux from the official site"

. $(dirname $0)/common.sh


[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

#arch=$($DISTRVENDOR --distro-arch)
arch=amd64
#pkgtype=$($DISTRVENDOR -p)
pkgtype=deb

PKG="https://download.onlyoffice.com/install/desktop/editors/linux/$(epm print constructname $PKGNAME "" $arch deb)"

epm install "$PKG"
