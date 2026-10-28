#!/bin/sh

PKGNAME=dorion
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Dorion - lightweight alternative Discord client"
URL="https://github.com/SpikeHD/Dorion"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"

# Since 7.0.1 RPMs use a shared libcef.so, while DEBs bundle CEF.
# Dorion 7.x provides CEF builds only for x86_64 and aarch64, so armhf is no longer supported.
if epm status --installable "libcef.so()(64bit)" ; then
    # Dorion_7.0.1-1.x86_64.rpm / Dorion_7.0.1-1.aarch64.rpm
    PKGURL="$(get_github_url SpikeHD/Dorion Dorion_${VERSION}-*.${arch}.rpm)"
else
    arch="$(epm print info --debian-arch)"
    # Dorion_7.0.1_amd64.deb / Dorion_7.0.1_arm64.deb
    PKGURL="$(get_github_url SpikeHD/Dorion Dorion_${VERSION}_${arch}.deb)"
fi

install_pkgurl
