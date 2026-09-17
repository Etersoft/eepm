#!/bin/sh

PKGNAME=cromite
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Chromium fork with ad blocking and privacy enhancements from the official site"
URL="https://github.com/uazo/cromite"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL=$(get_github_url "$URL/" "chrome-lin64.tar.gz*")

install_pack_pkgurl
