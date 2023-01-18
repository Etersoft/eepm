#!/bin/sh

PKGNAME=onlyoffice-desktopeditors
SUPPORTEDARCHES="x86_64"
DESCRIPTION="ONLYOFFICE for Linux from the official site"

. $(dirname $0)/common.sh

#arch=$($DISTRVENDOR --distro-arch)
arch=amd64
#pkgtype=$($DISTRVENDOR -p)
pkgtype=deb

PKG="https://download.onlyoffice.com/install/desktop/editors/linux/$(epm print constructname $PKGNAME "" $arch deb)"

epm install "$PKG"
