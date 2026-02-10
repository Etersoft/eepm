#!/bin/sh

PKGNAME=Throne
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Cross-platform GUI proxy utility (Empowered by sing-box)"
URL="https://github.com/throneproj/Throne"
. $(dirname $0)/common.sh

arch=$(epm print info --debian-arch)
PKGURL=$(get_github_url "https://github.com/throneproj/Throne" "${PKGNAME}-${VERSION}-linux-$arch.zip")

install_pack_pkgurl
