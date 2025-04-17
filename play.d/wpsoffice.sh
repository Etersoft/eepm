#!/bin/sh

PKGNAME=wpsoffice
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="WPS Office for Linux from the official site"
URL="https://www.wps.cn/product/wpslinux"
TIPS="Run epm play wpsoffice=<version> to install some specific version"

if epm installed wps-office ; then
    PKGNAME=wps-office
fi

if echo "$VERSION" | grep -q "^11" ; then
    PKGNAME=wps-office
fi

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION=$(eget -O- https://archive2.kylinos.cn/DEB/KYLIN_DEB/pool/main/deb/wpsoffice/ | grep -oP '[^/]+_\K[\d.]+(?=_amd64\.deb)' | sort -V | tail -n1)
fi

PKGURL="https://archive2.kylinos.cn/DEB/KYLIN_DEB/pool/main/deb/wpsoffice/wpsoffice_${VERSION}_amd64.deb"

# wps-office 12 need GLIBCXX_3.4.30
#is_stdcpp_enough "12.1" || VERSION="11.1.0.11723.XA"

if echo "$VERSION" | grep -q "^11" ; then
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
fi

install_pkgurl
