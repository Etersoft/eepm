#!/bin/sh

PKGNAME=QIDIStudio
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='QIDI Studio is a 3D slicer for QIDI printers (fork of Bambu Studio)'
URL="https://github.com/QIDITECH/QIDIStudio"

. $(dirname $0)/common.sh

# Ubuntu24 build needs GLIBC_2.38, Ubuntu22 build needs GLIBC_2.35
if is_glibc_enough 2.38 ; then
    build="Ubuntu24"
elif is_glibc_enough 2.35 ; then
    build="Ubuntu22"
else
    fatal "glibc 2.35 or above is required for $PKGNAME."
fi

# tag v2.07.02.60, file QIDIStudio_v02.07.02.60_Ubuntu24.AppImage
if [ "$VERSION" = "*" ] ; then
    PKGURL="$(get_github_url "$URL/" "QIDIStudio_v[0-9]*_${build}.AppImage")"
else
    PKGURL="$(get_github_url "$URL/" "QIDIStudio_v0${VERSION}_${build}.AppImage")"
fi

install_pack_pkgurl
