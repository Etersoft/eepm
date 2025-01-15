#!/bin/sh

PKGNAME=skypeforlinux
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Skype for Linux - Stable/Release Version from the official site"
URL="https://skype.com"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# https://snapcraft.io/skype https://aur.archlinux.org/packages/skypeforlinux-bin
PKGURL="$(snap_get_pkgurl https://snapcraft.io/skype)"

install_pack_pkgurl
