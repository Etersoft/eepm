#!/bin/sh

PKGNAME=wps-office
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="WPS Office for Linux from the official site"
URL="https://www.wps.com/ru-RU/"
TIPS="Run epm play wpsoffice=<version> to install some specific version"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -O- https://www.wps.com/whatsnew/linux/ | grep -oP "\W(\d+\.\d+\.\d+\.\d+)\W" | grep -oP "\d+\.\d+\.\d+\.\d+" | head -n1)
    VERSION="${VERSION}.XA"
fi

mversion=$(echo "$VERSION" | sed -e 's|\.XA$||' -e 's|.*\.||')
pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        PKGURL="https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/$mversion/wps-office-${VERSION}-1.x86_64.rpm"
        ;;
    *)
        PKGURL="https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/$mversion/wps-office_${VERSION}_amd64.deb"
        ;;
esac

install_pkgurl
