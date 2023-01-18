#!/bin/sh

PKGNAME=wps-office
SUPPORTEDARCHES="x86_64"
DESCRIPTION="WPS Office for Linux from the official site"

. $(dirname $0)/common.sh


# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=wps-office
pkgverstr=$(epm tool eget -O- "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=wps-office" | grep "^pkgver=")
eval $pkgverstr
[ -n "$pkgver" ] || pkgver=11.1.0.11664

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        PKG="https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/${pkgver##*.}/wps-office-${pkgver}.XA-1.x86_64.rpm"
        ;;
    deb)
        PKG="https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/${pkgver##*.}/wps-office_${pkgver}.XA_amd64.deb"
        ;;
    *)
        fatal "Package target $pkgtype is not supported yet"
        ;;
esac

case "$(epm print info -s)" in
  alt)
      # See in the package scripts: find /home/*/.config/Kingsoft/Office.conf
      epm install --repack $PKG
      exit
      ;;
esac

epm install "$PKG"
