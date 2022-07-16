#!/bin/sh

PKGNAME=viber
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Viber for Linux from the official site"

. $(dirname $0)/common.sh


# the same binaries in deb and rpm
PKG="https://download.cdn.viber.com/cdn/desktop/Linux/viber.deb"

epm install "$PKG"
