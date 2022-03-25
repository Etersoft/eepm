#!/bin/sh

PKGNAME=viber
DESCRIPTION="Viber for Linux from the official site"

. $(dirname $0)/common.sh


[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1


# the same binaries in deb and rpm
PKG="https://download.cdn.viber.com/cdn/desktop/Linux/viber.deb"

epm install "$PKG"
