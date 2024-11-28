#!/bin/sh

PKGNAME=epsonscan2-non-free-plugin
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Epson Scan 2 non-free-plugin - Linux Scanner Driver from the official site"
URL="https://support.epson.net/linux/en/epsonscan2.php"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype=$(epm print info -p)
arch="$(epm print info -a)"
case "$pkgtype-$arch" in
    rpm-x86_64)
        PKGURL="https://download3.ebz.epson.net/dsc/f/03/00/16/14/40/9cb99579f9fa7facf54f77f0ce6fe5600677f30a/epsonscan2-bundle-6.7.70.0.x86_64.rpm.tar.gz"
        ;;
    *-x86_64)
        PKGURL="https://download3.ebz.epson.net/dsc/f/03/00/16/14/38/7b1780ace96e2c6033bbb667c7f3ed281e4e9f38/epsonscan2-bundle-6.7.70.0.x86_64.deb.tar.gz"
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

install_pack_pkgurl
