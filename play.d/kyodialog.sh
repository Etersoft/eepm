#!/bin/sh

PKGNAME=kyodialog
SUPPORTEDARCHES="x86_64"
DESCRIPTION="KYOCERA Printing Package (Linux Universal Driver)"

. $(dirname $0)/common.sh


URL="https://www.kyoceradocumentsolutions.eu/content/download-center/eu/drivers/all/Linux_Universal_Driver_zip.download.zip"

# FIXME: ALT Linux only
epm assure erc || fatal

PKGDIR="$(mktemp -d)"
trap "rm -fr $PKGDIR" EXIT
cd $PKGDIR || fatal
epm tool eget "$URL" || fatal
a= erc Linux_Universal_Driver.zip || fatal
a= erc KyoceraLinuxPackages-*.tar.gz || fatal
cd KyoceraLinuxPackages-*.tar || fatal
cd Fedora/Global/kyodialog_x86_64 || fatal
epm --repack install kyodialog-9.*.x86_64.rpm
