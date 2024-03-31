#!/bin/sh

PKGNAME=pcsx2
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="PCSX2 - free and open-source PlayStation 2 (PS2) emulator from the official site"
URL="https://github.com/PCSX2/pcsx2/releases"

. $(dirname $0)/common.sh

# https://github.com/PCSX2/pcsx2/releases/download/v1.7.4767/pcsx2-v1.7.4767-linux-appimage-x64-Qt.AppImage
file="pcsx2-v${VERSION}-linux-appimage-x64-Qt.AppImage"

PKGURL=$(eget --list --latest https://github.com/PCSX2/pcsx2/releases "$file") || fatal "Can't get package URL"

install_pack_pkgurl
