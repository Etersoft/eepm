#!/bin/sh

PKGNAME=OrcaSlicer
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Orca Slicer is an open source slicer for FDM printers'
URL="https://github.com/SoftFever/OrcaSlicer"

. $(dirname $0)/common.sh

PKGURL="$(eget --list --latest "https://github.com/SoftFever/OrcaSlicer/releases/" "OrcaSlicer${VERSION}.AppImage")"

install_pack_pkgurl

