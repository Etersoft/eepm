#!/bin/sh

PKGNAME=raindrop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Raindrop.io from the snapcraft"
URL="https://snapcraft.io/raindrop"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="$(snap_get_pkgurl $URL)"
install_pkgurl
