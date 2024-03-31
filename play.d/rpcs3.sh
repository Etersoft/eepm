#!/bin/sh

PKGNAME=rpcs3
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="RPCS3 - free and open-source PlayStation 3 emulator from the official site"
URL="https://rpcs3.net/download"

. $(dirname $0)/common.sh

# https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-fff0c96bf38d1ada075e524c4753a7f263c06449/rpcs3-v0.0.18-12817-fff0c96b_linux64.AppImage
file="rpcs3-v${VERSION}-*-*_linux64.AppImage"

PKGURL=$(eget --list --latest https://github.com/RPCS3/rpcs3-binaries-linux/releases "$file")

install_pack_pkgurl
