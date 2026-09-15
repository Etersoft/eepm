#!/bin/sh

PKGNAME=koda
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Koda Desktop — AI assistant for developers'
URL="https://kodacode.ru/"

. $(dirname $0)/common.sh

# The vendor publishes one rolling AppImage for Linux x86_64. The generic
# AppImage packer reads X-AppImage-Version from the desktop entry, so package
# updates keep the actual upstream version instead of the "latest" filename.
warn_version_is_not_supported
PKGURL="https://download.kodacode.ru/download/Koda-Desktop-latest.AppImage"

install_pack_pkgurl
