#!/bin/sh

PKGNAME=brscan4
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Brother SANE scanner driver (DCP/MFC models)"
URL="http://support.brother.com"

. $(dirname $0)/common.sh

# Brother publishes only the current driver, older versions are not available
warn_version_is_not_supported

# direct link from https://support.brother.com (Linux scanner driver brscan4)
PKGURL="https://download.brother.com/welcome/dlf105203/brscan4-0.4.11-1.x86_64.rpm"

install_pkgurl || exit

echo
echo "Note: the SANE 'brother4' backend is registered automatically.
For a USB scanner just connect it and use any SANE frontend
(simple-scan, xsane, scanimage -L).
For a network scanner register it manually, for example:
# brsaneconfig4 -a name=SCANNER model=MFC-XXXX ip=192.168.0.100
"
