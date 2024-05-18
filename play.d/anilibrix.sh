#!/bin/sh

PKGNAME=Plus-linux
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Anilibria desktop anime cinema for any of your computers (unofficial client)"
URL="https://github.com/AnimeHaze/anilibrix-plus/"

. $(dirname $0)/common.sh

PKGURL=$(eget --list --latest https://github.com/AnimeHaze/anilibrix-plus/releases "AniLibrix.Plus-linux-x86_64-$VERSION.AppImage")

install_pkgurl