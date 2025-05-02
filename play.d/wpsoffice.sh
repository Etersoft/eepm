#!/bin/sh

PKGNAME=wps-office
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="WPS Office for Linux from the official site"
URL="https://www.wps.cn/product/wpslinux"
TIPS="Run epm play wpsoffice=<version> to install some specific version"

. $(dirname $0)/common.sh

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
