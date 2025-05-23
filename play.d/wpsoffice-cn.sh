#!/bin/sh

PKGNAME=wpsoffice
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="WPS Office for Linux from the official site (Chinese version)"
URL="https://www.wps.cn/product/wpslinux"
TIPS="Run epm play wpsoffice=<version> to install some specific version"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    #VERSION=$(eget -O- https://archive2.kylinos.cn/DEB/KYLIN_DEB/pool/main/deb/wpsoffice/ | grep -oP '[^/]+_\K[\d.]+(?=_amd64\.deb)' | sort -V | tail -n1)
    VERSION="$(eget -O- https://www.wps.cn/product/wpslinux | grep '"banner_txt"' | sed -e 's|.*banner_txt">||' -e "s|</p>||")"
    [ -n "$VERSION" ] || fatal "Can't get version"
fi

PKGURL="https://archive2.kylinos.cn/DEB/KYLIN_DEB/pool/main/deb/wpsoffice/wpsoffice_${VERSION}_amd64.deb"

install_pkgurl
