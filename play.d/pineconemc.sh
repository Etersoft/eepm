#!/bin/sh

PKGNAME=PineconeMC
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='A fork of Prism Launcher with integrated support for Ely.by accounts'
URL="https://github.com/ElyPrismLauncher/Launcher"

. $(dirname $0)/common.sh

warn_version_is_not_supported

epm assure unsquashfs squashfs-tools || fatal

arch="$(epm print info -a)"

PKGURL=$(get_github_url "$URL" "PineconeMC-Linux-$arch.AppImage")

install_pkgurl
