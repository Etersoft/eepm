#!/bin/sh

PKGNAME=ungoogled-chromium
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Google Chromium, sans integration with Google from the official site"
URL="https://github.com/ungoogled-software/ungoogled-chromium-portablelinux"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    # ungoogled-chromium_136.0.7103.59-1_linux.tar.xz
    PKGURL=$(get_github_url "https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/" "ungoogled-chromium_${VERSION}_linux.tar.xz")
else
    # https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/releases/download/134.0.6998.88-1/ungoogled-chromium_134.0.6998.88-1_linux.tar.xz
    VERSION="$VERSION-1"
    PKGURL="https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/releases/download/$VERSION/ungoogled-chromium_${VERSION}_linux.tar.xz"
fi

install_pack_pkgurl
