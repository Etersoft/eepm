#!/bin/sh

PKGNAME=kyodialog
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="KYOCERA Printing Package (Linux Universal Driver)"

. $(dirname $0)/common.sh

warn_version_is_not_supported

URL="https://www.kyoceradocumentsolutions.eu/content/download-center/eu/drivers/all/Linux_Universal_Driver_zip.download.zip"

epm pack --install kyodialog "$URL"
