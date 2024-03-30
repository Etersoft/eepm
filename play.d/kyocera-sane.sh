#!/bin/sh

PKGNAME=kyocera-sane
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Kyocera sane scanner support package"
URL="https://www.kyoceradocumentsolutions.eu/en/support/downloads.name-L2V1L2VuL21mcC9FQ09TWVNNNjIzMENJRE4=.html"

. $(dirname $0)/common.sh

warn_version_is_not_supported
URL="https://www.kyoceradocumentsolutions.de/content/download-center/de/drivers/all/SANE_Driver_zip.download.zip"

epm pack --install $PKGNAME "$URL"
