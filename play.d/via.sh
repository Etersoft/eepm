#!/bin/sh

PKGNAME=via
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="VIA keyboard configurator for QMK/VIA firmware keyboards"
URL="https://github.com/the-via/releases"

. $(dirname $0)/common.sh

PKGURL=$(get_github_url the-via/releases "via-${VERSION}-linux.AppImage")

install_pkgurl
