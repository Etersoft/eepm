#!/bin/sh

PKGNAME=OrcaSlicer
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='Orca Slicer is an open source slicer for FDM printers'
URL="https://github.com/OrcaSlicer/OrcaSlicer"

. $(dirname $0)/common.sh

# the AppImage is built on Ubuntu 24.04 and needs GLIBC_2.38
is_glibc_enough 2.38 || fatal "glibc 2.38 or above is required for $PKGNAME."

case "$(epm print info -a)" in
    aarch64)
        arch="_aarch64"
        ;;
    *)
        arch=""
        ;;
esac

case "$VERSION" in
    1.*|2.0.*|2.1.*|2.2.*)
        # https://github.com/OrcaSlicer/OrcaSlicer/releases/download/v2.2.0/OrcaSlicer_Linux_V2.2.0.AppImage
        [ -z "$arch" ] || fatal "There is no aarch64 build for $PKGNAME $VERSION."
        mask="OrcaSlicer_Linux_V${VERSION}.AppImage"
        ;;
    *)
        [ "$VERSION" = "*" ] && VERSION="[0-9]*[0-9]"
        # https://github.com/OrcaSlicer/OrcaSlicer/releases/download/v2.4.2/OrcaSlicer_Linux_AppImage_Ubuntu2404_V2.4.2.AppImage
        mask="OrcaSlicer_Linux_AppImage_Ubuntu2404${arch}_V${VERSION}.AppImage"
        ;;
esac

PKGURL="$(get_github_url "$URL/" "$mask")"

install_pack_pkgurl
