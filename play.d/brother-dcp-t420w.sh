#!/bin/sh

PKGNAME=brother-dcp-t420w
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Brother DCP-T420W inkjet printer driver (CUPS) from the official site"
URL="https://support.brother.com"

. $(dirname $0)/common.sh

# the vendor publishes only the current driver, older versions are not archived
warn_version_is_not_supported

# upstream deb package name is dcpt420wpdrv, we publish it as brother-dcp-t420w
export EPM_REPACK_SCRIPT=brother-dcp-t420w
export EEPM_INTERNAL_PKGNAME='dcpt420wpdrv brother-dcp-t420w'

# vendor driver deb (direct link, the only version published by Brother);
# x86_64 native binaries are used (see repack.d/brother-dcp-t420w.sh)
PKGURL="https://download.brother.com/welcome/dlf105168/dcpt420wpdrv-3.5.0-1.i386.deb"

install_pkgurl || exit

echo
echo "Note: the driver and its PPD are installed.
To add the printer, connect it via USB or Wi-Fi and add it in your print settings
(System Settings -> Printers, system-config-printer, or the CUPS web UI at
http://localhost:631/), choosing the 'Brother DCP-T420W' model.
For scanning, install the brscan4 driver separately."
