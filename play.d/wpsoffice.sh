#!/bin/sh

PKGNAME=wps-office
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="WPS Office for Linux from the official site"
URL="https://www.wps.com/ru-RU/"
TIPS="Run epm play wpsoffice=<version> to install some specific version"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=wps-office
    pkgverstr=$(epm tool eget -O- "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=wps-office" | grep "^pkgver=")
    eval $pkgverstr
    [ -n "$pkgver" ] || pkgver=11.1.0.11664
    VERSION="$pkgver.XA"
fi

mversion=$(echo "$VERSION" | sed -e 's|\.XA$||' -e 's|.*\.||')
pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        PKG="https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/$mversion/wps-office-${VERSION}-1.x86_64.rpm"
        ;;
    *)
        PKG="https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/$mversion/wps-office_${VERSION}_amd64.deb"
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
