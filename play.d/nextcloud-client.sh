#!/bin/sh

PKGNAME=Nextcloud
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Nextcloud desktop sync client from the official site"
URL="https://nextcloud.com/install/#install-clients"

. $(dirname $0)/common.sh

PKGURL=$(get_github_url "nextcloud-releases/desktop" "Nextcloud-${VERSION}-x86_64.AppImage")

install_pkgurl
