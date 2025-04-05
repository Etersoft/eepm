#!/bin/sh

PKGNAME=Vesktop
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='A cross platform electron-based desktop app aiming to give you a snappier Discord experience with Vencord pre-installed'
URL="https://github.com/Vencord/Vesktop"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch="$(epm print info --debian-arch)"

PKGURL="https://vencord.dev/download/vesktop/$arch/appimage"

install_pkgurl

