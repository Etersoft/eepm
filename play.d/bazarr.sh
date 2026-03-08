#!/bin/sh

PKGNAME=bazarr
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION="Bazarr subtitle manager for Sonarr and Radarr"
URL="https://github.com/morpheus65535/bazarr"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "bazarr.zip")
else
    PKGURL="$URL/releases/download/v${VERSION}/bazarr.zip"
fi

install_pack_pkgurl
