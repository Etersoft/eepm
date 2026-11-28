#!/bin/sh

PKGNAME=artipic
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Artipic Photo Editor (raster graphics editor) from the official site"
URL="https://www.artipic.ru/"

. $(dirname $0)/common.sh

# the vendor keeps only the current build at unversioned links
warn_version_is_not_supported

# The same build is published as ArtipicSetup_RedOS_x86_64.rpm (wants system ICU 65 and libjpeg 8),
# ArtipicSetup_Astra_amd64.deb (bundles ICU, libjpeg, libtiff, dcraw) and ArtipicSetup_Linux.AppImage.
# Use the deb as the most self-contained package.
PKGURL="https://www.artipic.ru/distribution/ArtipicSetup_Astra_amd64.deb"

install_pkgurl
