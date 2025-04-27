#!/bin/sh

PKGNAME=z-library
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Z-Library Desktop Launcher"
URL="https://ru.wikipedia.org/wiki/Z-Library"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://s3proxy.cdn-zlib.sk/te_public_files/soft/linux/zlibrary-setup-latest.rpm"

install_pkgurl
