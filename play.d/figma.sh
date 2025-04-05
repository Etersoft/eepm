#!/bin/sh

PKGNAME=figma-linux
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Figma-linux - an unofficial Electron-based Figma desktop app for Linux"
URL="https://github.com/Figma-Linux/figma-linux"

. $(dirname $0)/common.sh

[ "$VERSION" = "*" ] && VERSION="[0-9]*"

pkgtype="$(epm print info -p)"
arch="$(epm print info --distro-arch)"

file="${PKGNAME}_${VERSION}_linux_$arch.$pkgtype"

PKGURL=$(eget --list --latest https://github.com/Figma-Linux/figma-linux/releases "$file")

install_pkgurl

