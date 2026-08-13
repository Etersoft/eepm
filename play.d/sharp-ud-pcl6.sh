#!/bin/sh

PKGNAME=sharp-ud-pcl6
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Sharp Universal PCL6 printer driver for Linux"
URL="https://sharpone.sharp.co.uk/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# Sharp blocks direct downloads in some regions. Run: epm play --ipfs sharp-ud-pcl6
PKGURL="https://sharpone.sharp.co.uk/api/pim/download/161e02c5-0073-4ded-a874-c13585b67b78"
PKGSUM="sha256:8a804fe78a3950a6ca137e91dfac2de0f952589b0b6674ba903204c6a7a0f495"

install_pack_pkgurl "1.18" "$PKGSUM"

echo "Note: run
# serv cups restart
to enable new Sharp Universal Color and Mono PCL6 printer models in cups
"
