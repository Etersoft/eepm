#!/bin/sh

PKGNAME="far2l-portable"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="FAR2L Portable from the official site"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL=$(get_github_version "https://github.com/spvkgn/far2l-portable/" "far2l.*x86_64.*.AppImage.tar")

install_pack_pkgurl
