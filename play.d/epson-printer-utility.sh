#!/bin/sh

PKGNAME=epson-printer-utility
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Epson Printer Utility - Linux Epson Printer Utility from the official site"
URL="https://support.epson.net/linux/Printer/LSB_distribution_pages/en/utility.php"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype=$(epm print info -p)
arch="$(epm print info -a)"
case "$pkgtype-$arch" in
    rpm-x86_64)
        PKGURL="https://download3.ebz.epson.net/dsc/f/03/00/15/43/24/e0c56348985648be318592edd35955672826bf2c/epson-printer-utility-1.1.3-1.x86_64.rpm"
        ;;
    *-x86_64)
        PKGURL="https://download3.ebz.epson.net/dsc/f/03/00/15/43/23/b85f4cf2956db3dd768468b418b964045c047b2c/epson-printer-utility_1.1.3-1_amd64.deb"
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

install_pkgurl || exit

echo
echo "Note: run
# serv ecbd on
to enable needed epson-printer-utility system service
"