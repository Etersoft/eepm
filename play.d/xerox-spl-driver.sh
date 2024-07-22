#!/bin/sh

PKGNAME=xerox-spl-driver
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Xerox SPL Linux Driver for printers and scanners"
URL="https://www.support.xerox.com"

. $(dirname $0)/common.sh

warn_version_is_not_supported


PKGURL="http://download.support.xerox.com/pub/drivers/B215/drivers/linux/ar/Xerox_B215_Linux_PrintDriver_Utilities.tar.gz"

install_pack_pkgurl

echo "Note: run
# serv cups restart
to enable new printer model in cups
"