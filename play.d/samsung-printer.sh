#!/bin/sh

# the SULDR driver package embeds its version in the package name (suld-driver2-<ver>)
PKGNAME=suld-driver2-1.00.39
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Samsung Unified Linux Driver (universal printer/scanner driver) from the SULDR repository"
URL="https://www.bchemnet.com/suldr/"

. $(dirname $0)/common.sh

# the SULDR repo publishes only the current universal driver
warn_version_is_not_supported

export EEPM_INTERNAL_PKGNAME="$PKGNAME"

# the driver ships 32-bit binaries; on ALT pull the 32-bit libusb-0.1 compat lib
# (the repacked soname require does not pull it automatically)
[ "$(epm print info -s)" = "alt" ] && epm install --skip-installed i586-libusb-compat

# universal SULD driver from the community Samsung Unified Linux Driver Repository
# (covers most Samsung ML/SCX/CLP/Xpress models)
PKGURL="https://www.bchemnet.com/suldr/pool/debian/extra/su/suld-driver2_1.00.39-2_i386.deb"

install_pkgurl || exit

echo
echo "Note: the Samsung printer/scanner driver and PPDs are installed.
To add the printer, add it in your print settings (System Settings -> Printers,
system-config-printer, or the CUPS web UI at http://localhost:631/), choosing
your Samsung model."
