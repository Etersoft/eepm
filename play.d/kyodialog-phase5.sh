#!/bin/sh

PKGNAME=kyodialog-phase5
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="KYOCERA Printing Package (Linux Universal Driver)"
URL="https://www.kyoceradocumentsolutions.eu/en/support/downloads.name-L2V1L2VuL21mcC9FQ09TWVNNMjAzNURO.html#tab=driver"

. $(dirname $0)/common.sh

warn_version_is_not_supported

#PKGURL="https://www.kyoceradocumentsolutions.eu/content/download-center/eu/drivers/all/Linux_Universal_Driver_zip.download.zip"
PKGURL="https://www.kyoceradocumentsolutions.eu/content/download-center/eu/drivers/all/KyoceraLinux_Phase5_2018_08_29_zip.download.zip"

install_pack_pkgurl
