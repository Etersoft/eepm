#!/bin/sh

PKGNAME=Telega
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Telega messenger (WARNING: your account data may not be safe)"
URL="https://telega.me"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL=$(get_github_url "Telegru/tdesktop" "Telega_Linux.tar.xz")

install_pack_pkgurl
