#!/bin/sh

PKGNAME=kodak-i11xx
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Kodak ScanMate I1150 Scanner Driver"
URL="https://www.kodakalaris.com/en/scanners/scanmate-i1150-scanner"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://resources.kodakalaris.com/docimaging/drivers/i1100Series/LinuxSoftware_i11xx_v2.16.x86_64.deb.tar.gz"

install_pack_pkgurl
