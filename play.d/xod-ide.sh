#!/bin/sh

PKGNAME=xod-client-electron
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="A visual programming language for microcontrollers"
URL="https://xod.io/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://www.googleapis.com/download/storage/v1/b/releases.xod.io/o/v0.38.0%2Fxod-client-electron-0.38.0.x86_64.rpm?generation=1615553616000093&alt=media"

repack=''
[ "$(epm print info -s)" = "alt" ] && repack="--repack"

epm $repack install "$PKGURL"
