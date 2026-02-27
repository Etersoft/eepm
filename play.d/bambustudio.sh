#!/bin/sh

PKGNAME=BambuStudio
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Bambu Studio is a 3D slicer for Bambu Lab and other FDM printers (fork of PrusaSlicer)"
URL="https://github.com/bambulab/BambuStudio"

. $(dirname $0)/common.sh

pkgtype=$(epm print info -p)

case "$pkgtype" in
    rpm)
        mask="Bambu_Studio_linux_fedora-*.AppImage"
        ;;
    *)
        mask="Bambu_Studio_ubuntu-24.04*.AppImage"
        ;;
esac

PKGURL="$(eget --list --latest "$URL/releases" "$mask")"

install_pack_pkgurl
