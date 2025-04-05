#!/bin/sh

PKGNAME=iptvnator
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='IPTV player from the official site'
URL="https://github.com/4gray/iptvnator"

. $(dirname $0)/common.sh

arch=$(epm print info --debian-arch)

pkgtype=deb

PKGURL=$(eget --list --latest https://github.com/4gray/iptvnator/releases/ "$PKGNAME*$VERSION*$arch.$pkgtype")

install_pkgurl
