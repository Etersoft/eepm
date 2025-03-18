#!/bin/sh

PKGNAME=whatsie
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Whatsie from the snapcraft (WhatsApp for Linux)"
URL="https://snapcraft.io/whatsie"

. $(dirname $0)/common.sh

PKGURL="$(snap_get_pkgurl $URL)"
install_pkgurl
