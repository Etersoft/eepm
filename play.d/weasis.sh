#!/bin/sh

PKGNAME=weasis
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION="Weasis DICOM medical viewer"
URL="https://github.com/nroduit/Weasis"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/nroduit/Weasis/" "weasis_.$VERSION-1_$arch.deb")
else
    PKGURL="https://github.com/nroduit/Weasis/releases/download/v$VERSION/weasis_$VERSION-1_$arch.deb"
fi

install_pkgurl
