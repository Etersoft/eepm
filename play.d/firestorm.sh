#!/bin/sh

PKGNAME=firestorm
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Firestorm Second Life viewer'
URL="https://www.firestormviewer.org/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://downloads.firestormviewer.org/release/linux/Phoenix-Firestorm-Releasex64-6-6-17-70368.tar.xz"

install_pack_pkgurl
