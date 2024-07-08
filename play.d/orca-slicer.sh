#!/bin/sh

PKGNAME=OrcaSlicer
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Orca Slicer is an open source slicer for FDM printers'
URL="https://github.com/SoftFever/OrcaSlicer"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] && VERSION="[0-9].*[0-9]"

PKGURL="$(get_github_version "https://github.com/SoftFever/OrcaSlicer/" "OrcaSlicer_Linux_V${VERSION}.AppImage")"

install_pack_pkgurl
