#!/bin/sh

PKGNAME=penpot-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Penpot Desktop from the snapcraft"
URL="https://snapcraft.io/penpot-desktop"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="$(snap_get_pkgurl $URL)"
install_pkgurl
