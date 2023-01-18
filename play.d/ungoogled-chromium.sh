#!/bin/sh

PKGNAME=ungoogled-chromium
SUPPORTEDARCHES="x86_64"
DESCRIPTION='' #"Google Chromium, sans integration with Google from the official site"

. $(dirname $0)/common.sh

PKG=$(epm tool eget --list --latest https://github.com/clickot/ungoogled-chromium-binaries/releases ungoogled-chromium_*_linux.tar.xz) || fatal "Can't get package URL"

epm install "$PKG"
