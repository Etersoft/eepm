#!/bin/sh

# the SULDR driver package embeds its version in the package name (suld-driver2-<ver>)
PKGNAME="suld-driver2-1.00.39 suld-driver2-common-1 suld-ppd-4"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Samsung Unified Linux Driver (universal printer/scanner driver) from the SULDR repository"
URL="https://www.bchemnet.com/suldr/"

. $(dirname $0)/common.sh

# the SULDR repo publishes only the current universal driver
warn_version_is_not_supported

# universal SULD driver from the community Samsung Unified Linux Driver Repository
# (covers most Samsung ML/SCX/CLP/Xpress models)
REPOURL="https://www.bchemnet.com/suldr/pool/debian/extra/su"
PKGURL="$REPOURL/suld-driver2-common-1_1-14_all.deb
$REPOURL/suld-ppd-4_1.00.39-2_all.deb
$REPOURL/suld-driver2_1.00.39-2_amd64.deb"

# The native Debian common package depends on SULDR's keyring.
[ "$PKGFORMAT" = "deb" ] && PKGURL="$REPOURL/suldr-keyring_4_all.deb $PKGURL"

install_pkgurl || exit

echo
echo "Note: the Samsung printer/scanner driver and PPDs are installed.
To add the printer, add it in your print settings (System Settings -> Printers,
system-config-printer, or the CUPS web UI at http://localhost:631/), choosing
your Samsung model."
