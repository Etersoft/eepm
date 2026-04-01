#!/bin/sh

PKGNAME=epsonscan2
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Epson Scan 2 - Linux Scanner Driver from the official site"
URL="https://support.epson.net/linux/en/epsonscan2.php"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# download-center.epson.com API is blocked from datacenter IPs, use direct URLs
pkgtype=$(epm print info -p)
case "$pkgtype" in
    rpm)
        PKGURL="https://download3.ebz.epson.net/dsc/f/03/00/16/14/40/9cb99579f9fa7facf54f77f0ce6fe5600677f30a/epsonscan2-bundle-6.7.70.0.x86_64.rpm.tar.gz"
        ;;
    *)
        PKGURL="https://download3.ebz.epson.net/dsc/f/03/00/16/14/38/7b1780ace96e2c6033bbb667c7f3ed281e4e9f38/epsonscan2-bundle-6.7.70.0.x86_64.deb.tar.gz"
        ;;
esac

install_pack_pkgurl
