#!/bin/sh

PKGNAME="GitHubDesktop-linux"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="GitHub Desktop is an open-source Electron-based GitHub app"
URL="https://github.com/shiftkey/desktop"

. $(dirname $0)/common.sh

PKGURL=$(eget --list --latest https://github.com/shiftkey/desktop/releases "GitHubDesktop-linux-x86_64-$VERSION-linux1.AppImage")

install_pkgurl
