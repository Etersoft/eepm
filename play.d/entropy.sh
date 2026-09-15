#!/bin/sh

PKGNAME=entropy
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Entropy keyboard configurator for Vial-QMK and Vial-RMK devices"
URL="https://github.com/ergohaven/entropy"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "$URL" "entropy-v*-x86_64.AppImage")
else
    PKGURL="$URL/releases/download/v$VERSION/entropy-v$VERSION-x86_64.AppImage"
fi

install_pack_pkgurl
