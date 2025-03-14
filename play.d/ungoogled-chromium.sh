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

[ "$VERSION" != "*" ] && VERSION="$VERSION-1.1"

# https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/releases/download/134.0.6998.88-1/ungoogled-chromium_134.0.6998.88-1_linux.tar.xz
PKGURL=$(eget --list --latest https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/releases "ungoogled-chromium_${VERSION}_linux.tar.xz")

install_pack_pkgurl
