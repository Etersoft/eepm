#!/bin/sh

PKGNAME="mfcl2700dnlpr mfcl2700dncupswrapper"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Brother MFC-L2700DN laser printer driver (LPR + CUPS wrapper) from the official site"
URL="https://support.brother.com"

. $(dirname $0)/common.sh

# the vendor publishes only the current driver, older versions are not archived
warn_version_is_not_supported

# two upstream i386 packages (lpr + cupswrapper), installed together; keep their
# names so the repack package-name check passes for both
export EEPM_INTERNAL_PKGNAME="$PKGNAME"

# direct vendor links (the only version Brother publishes for this model)
BASE="https://download.brother.com/welcome"
PKGURL="$BASE/dlf102083/mfcl2700dnlpr-3.2.0-1.i386.rpm $BASE/dlf102084/mfcl2700dncupswrapper-3.2.0-1.i386.rpm"

install_pkgurl || exit

echo
echo "Note: the LPR and CUPS wrapper drivers and the PPD are installed.
To add the printer, add it in your print settings (System Settings -> Printers,
system-config-printer, or the CUPS web UI at http://localhost:631/), choosing
the 'Brother MFC-L2700DN' model.
For scanning, install the brscan4 driver separately."
