#!/bin/sh

PKGNAME=steamcmd
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Steam Command Line Tools"
URL="http://developer.valvesoftware.com/wiki/SteamCMD"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# Use latest because I dont know version https://aur.archlinux.org/packages/steamcmd
VERSION="latest"

PKGURL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"

install_pack_pkgurl $VERSION

echo
echo "Note: Run steamcmd with no arguments before first use."
