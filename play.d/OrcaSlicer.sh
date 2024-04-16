#!/bin/sh

PKGNAME=OrcaSlicer
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Orca Slicer is an open source slicer for FDM printers'
URL="https://github.com/SoftFever/OrcaSlicer"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] && VERSION="[0-9]*[0-9]"
PKGURL="$(eget --list --latest "https://github.com/SoftFever/OrcaSlicer/releases/" "OrcaSlicer_Linux_V${VERSION}.AppImage")"

install_pack_pkgurl

