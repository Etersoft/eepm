#!/bin/sh

PKGNAME=brother-dcp-t510w
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Brother DCP-T510W inkjet printer driver (CUPS) from the official site"
URL="https://support.brother.com"

. $(dirname $0)/common.sh

# the vendor publishes only the current driver, older versions are not archived
warn_version_is_not_supported

# upstream rpm package name is dcpt510wpdrv, we publish it as brother-dcp-t510w
export EPM_REPACK_SCRIPT=brother-dcp-t510w
export EEPM_INTERNAL_PKGNAME='dcpt510wpdrv brother-dcp-t510w'

# vendor i386 driver rpm (direct link, the only version published by Brother).
# the driver binaries are 32-bit, so repack.d pulls the i586- compat runtime libs.
PKGURL="https://download.brother.com/welcome/dlf103621/dcpt510wpdrv-1.0.1-0.i386.rpm"

install_pkgurl || exit

echo
echo "Note: the driver and its PPD are installed.
To add the printer, connect it via USB or Wi-Fi and add it in your print settings
(System Settings -> Printers, system-config-printer, or the CUPS web UI at
http://localhost:631/), choosing the 'Brother DCP-T510W' model.
For scanning, install the brscan4 driver separately."
