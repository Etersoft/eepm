#!/bin/sh

PKGNAME=ungoogled-chromium
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Google Chromium, sans integration with Google from the official site"
URL="https://github.com/ungoogled-software/ungoogled-chromium-portablelinux"

. $(dirname $0)/common.sh

# keep old version due libc.so.6(GLIBC_2.33)(64bit)
if [ "$VERSION" = "*" ] && ! is_glibc_enough 2.35 ; then
    VERSION="113.0.5672.127"
fi

if [ "$VERSION" = "*" ] ; then
    # ungoogled-chromium_136.0.7103.59-1_linux.tar.xz
    PKGURL=$(get_github_url "https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/" "ungoogled-chromium_${VERSION}_linux.tar.xz")
else
    # https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/releases/download/134.0.6998.88-1/ungoogled-chromium_134.0.6998.88-1_linux.tar.xz
    VERSION="$VERSION-1"
    PKGURL=$(eget --list --latest https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/releases "ungoogled-chromium_${VERSION}_linux.tar.xz")
fi

install_pack_pkgurl
