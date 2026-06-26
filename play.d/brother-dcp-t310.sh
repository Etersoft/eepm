#!/bin/sh

PKGNAME=brother-dcp-t310
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Brother DCP-T310 inkjet printer driver (CUPS) from the official site"
URL="https://support.brother.com"

. $(dirname $0)/common.sh

# the vendor publishes only the current driver, older versions are not archived
warn_version_is_not_supported

# upstream rpm package name is dcpt310pdrv, we publish it as brother-dcp-t310
export EPM_REPACK_SCRIPT=brother-dcp-t310
export EEPM_INTERNAL_PKGNAME='dcpt310pdrv brother-dcp-t310'

# vendor i386 driver rpm (direct link, the only version published by Brother)
PKGURL="https://download.brother.com/welcome/dlf103619/dcpt310pdrv-1.0.1-0.i386.rpm"

install_pkgurl || exit

echo
echo "Note: the driver and its PPD are installed.
To add the printer, connect it via USB and add it in your print settings
(System Settings -> Printers, system-config-printer, or the CUPS web UI at
http://localhost:631/), choosing the 'Brother DCP-T310 CUPS' model.
"
