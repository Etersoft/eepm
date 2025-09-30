#!/bin/sh

PKGNAME=popcorn-time-nightly
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Popcorn Time is a multi-platform, free software BitTorrent client that includes an integrated media player'
URL="https://github.com/popcorn-official/popcorn-desktop"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL=$(eget --list https://popcorntime.app/download "*.deb")

# repack always, ever for deb system (bad postinst script)
install_pkgurl --repack
