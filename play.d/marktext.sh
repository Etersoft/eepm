#!/bin/sh

PKGNAME=marktext
SUPPORTEDARCHES="aarch64"
DESCRIPTION=' A simple and elegant open-source markdown editor that focused on speed and usability.'
URL="https://github.com/peterjthomson/marktext"

. $(dirname $0)/common.sh

# appimage and tar.gz contain only ARM64 binaries /opt/marktext/marktext: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1
PKGURL=$(get_github_url "https://github.com/peterjthomson/marktext" "marktext-linux-${VERSION}.AppImage")

install_pkgurl
