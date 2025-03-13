#!/bin/sh

PKGNAME=gdlauncher
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="All-In-One Minecraft Modded Launcher"
URL="https://gdlauncher.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://gdlauncher.com/download/linux"

install_pack_pkgurl
