#!/bin/sh

PKGNAME=kyodialog
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="KYOCERA Printing Package (Linux Universal Driver)"
URL="https://www.kyoceradocumentsolutions.com/download/model_ru.html?r=92&s=23&m=255&p=50"

. $(dirname $0)/common.sh

warn_version_is_not_supported

#PKGURL="https://www.kyoceradocumentsolutions.eu/content/download-center/eu/drivers/all/Linux_Universal_Driver_zip.download.zip"
PKGURL="https://dam.kyoceradocumentsolutions.com/content/dam/gdam_dc/dc_global/executables/web/KyoceraLinuxPackages-20230720.tar.gz"

install_pack_pkgurl
