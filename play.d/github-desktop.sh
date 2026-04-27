#!/bin/sh

PKGNAME="GitHubDesktop"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="GitHub Desktop is an open-source Electron-based GitHub app"
URL="https://github.com/shiftkey/desktop"

. $(dirname $0)/common.sh

PKGURL=$(get_github_url "https://github.com/shiftkey/desktop/" "GitHubDesktop-linux-x86_64-$VERSION-linux1.AppImage")

install_pkgurl
