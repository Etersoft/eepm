#!/bin/sh

PKGNAME=ungoogled-chromium
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="Google Chromium, sans integration with Google from the official site"
URL="https://github.com/ungoogled-software/ungoogled-chromium-portablelinux"

. $(dirname $0)/common.sh

arch="$(epm print info --distro-arch)"
[ "$arch" = "aarch64" ] && arch="arm64"

if [ "$VERSION" = "*" ] ; then
    # ungoogled-chromium-145.0.7632.75-1-x86_64_linux.tar.xz
    PKGURL=$(get_github_url "$URL/" "ungoogled-chromium-${VERSION}-${arch}_linux.tar.xz")
else
    VERSION="${VERSION}-${RELEASE}"
    PKGURL="$URL/releases/download/${VERSION}/ungoogled-chromium-${VERSION}-${arch}_linux.tar.xz"
fi

install_pack_pkgurl
