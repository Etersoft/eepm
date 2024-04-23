#!/bin/sh

PKGNAME=lexmark-upd-ppd
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Linux Universal Print Driver with 64-bit packaging for Lexmark Printers"
URL="https://support.lexmark.com/content/support/en_xm/support/download.DRI1000577.html"

. $(dirname $0)/common.sh

warn_version_is_not_supported


PKGURL="https://downloads.lexmark.com/downloads/drivers/Lexmark-UPD-PPD-Files-1.0-05252022.x86_64.rpm"

install_pack_pkgurl

echo "Note: run
# serv cups restart
to enable new printer model in cups
"