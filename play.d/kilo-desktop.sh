#!/bin/sh

PKGNAME=kilo-desktop
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Kilo Desktop is an AI coding and data workspace"
URL="https://kilo.ai/install"

. "$(dirname "$0")/common.sh"

warn_version_is_not_supported

arch="$(epm print info --debian-arch)"
[ "$arch" = amd64 ] && arch=x64
PKGURL="https://autoupdate.desktop.anaconda.com/kilo-desktop/latest/latest/linux/${arch}/kilo-desktop.deb"

install_pkgurl
