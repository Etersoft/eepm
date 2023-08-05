#!/bin/sh

PKGNAME=ungoogled-chromium
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Google Chromium, sans integration with Google from the official site"

. $(dirname $0)/common.sh

# keep old version due libc.so.6(GLIBC_2.33)(64bit)
if [ "$VERSION" = "*" ] && ! is_glibc_enough 2.35 ; then
    VERSION="113.0.5672.127"
fi

[ "$VERSION" != "*" ] && VERSION="$VERSION-1.1"

PKG=$(epm tool eget --list --latest https://github.com/clickot/ungoogled-chromium-binaries/releases ungoogled-chromium_${VERSION}_linux.tar.xz) || fatal "Can't get package URL"

epm install "$PKG"
