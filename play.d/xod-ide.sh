#!/bin/sh

PKGNAME=xod-client-electron
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="A visual programming language for microcontrollers"
URL="https://xod.io/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype=$(epm print info -p)
case $pkgtype in
    rpm)
        # https://www.googleapis.com/download/storage/v1/b/releases.xod.io/o/v0.38.0%2Fxod-client-electron-0.38.0.x86_64.rpm?generation=1615553616000093&alt=media
        mask="xod-client-electron*.x86_64.rpm*"
        ;;
    *)
        # https://www.googleapis.com/download/storage/v1/b/releases.xod.io/o/v0.38.0%2Fxod-client-electron_0.38.0_amd64.deb?generation=1615553616049782&alt=media
        mask="xod-client-electron_*_amd64.deb*"
        ;;
esac

PKGURL=$(eget --list --latest https://xod.io/ "$mask") || fatal "Can't get package URL"

install_pkgurl
