#!/bin/sh

PKGNAME=kyocera-fs-gdi
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Kyocera FS-1020/1025/1040/1060/1120/1125 GDI printer driver (PPD + rastertokpsl)"
URL="https://www.kyoceradocumentsolutions.eu/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://www.kyoceradocumentsolutions.eu/content/dam/download-center-cf/eu/drivers/all/LinuxDrv_1_1203_FS_1x2xMFP_zip.download.zip"

install_pack_pkgurl
