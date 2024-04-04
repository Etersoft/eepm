#!/bin/sh

PKGNAME=raindrop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Raindrop.io from the snapcraft"
URL="https://snapcraft.io/raindrop"

. $(dirname $0)/common.sh

PKGURL="$(snap_get_pkgurl $PKGNAME)"
install_pkgurl
