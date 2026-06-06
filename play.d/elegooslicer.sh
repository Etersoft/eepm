#!/bin/sh

PKGNAME=ElegooSlicer
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='ElegooSlicer is an open source slicer for FDM printers (OrcaSlicer fork)'
URL="https://github.com/ELEGOO-3D/ElegooSlicer"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] && VERSION="[0-9]*[0-9]"
PKGURL="$(get_github_url "https://github.com/ELEGOO-3D/ElegooSlicer/" "ElegooSlicer_Linux_V${VERSION}.AppImage")"

install_pkgurl
