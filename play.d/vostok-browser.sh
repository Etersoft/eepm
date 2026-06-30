#!/bin/sh

PKGNAME=vostok-browser
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='C01-03 Vostok web browser (Firefox-based)'
URL="https://c01-03.ru"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# the app ships as a tarball of flatpak bundles; erc unpacks them via ostree
# (no flatpak needed), so make sure ostree is available for the pack step
epm assure ostree || fatal

# the vendor publishes only the current version
PKGURL="https://download.c01-03.ru/vostok/vostok.tar.gz"

install_pack_pkgurl
