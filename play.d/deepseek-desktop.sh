#!/bin/sh

PKGNAME=deepseek-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Unofficial Web app for DeepSeek from the snapcraft"
URL="https://snapcraft.io/deepseek-desktop"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="$(snap_get_pkgurl $URL)"
install_pkgurl
