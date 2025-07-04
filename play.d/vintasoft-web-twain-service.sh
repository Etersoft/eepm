#!/bin/sh

PKGNAME=VintasoftWebTwainService
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Vintasoft Web TWAIN service (Linux edition)"
URL="https://demos.vintasoft.com/AspNetCoreTwainScanningDemo/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# rpm is more correct (see deb's postin script)
PKGURL=$(eget --list --latest https://demos.vintasoft.com/AspNetCoreTwainScanningDemo "VintasoftWebTwainService-*.rpm")

# TODO: just pack /etc/systemd/system/kestrel-VintasoftWebTwainService.service (created after /register)
epm install --scripts $PKGURL || exit

echo "Warning! This service scans your files (it was catched with long disk activity)!"
