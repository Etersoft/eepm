#!/bin/sh

PKGNAME=deepseek-harness-desktop
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Deepseek Harness Desktop (DSH) - desktop app for DeepSeek Harness from the official site"
URL="https://github.com/dsh-tauri/deepseek-harness-desktop"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/dsh-tauri/deepseek-harness-desktop/" "Deepseek.Harness.Desktop_${VERSION}_$arch.deb")
else
    PKGURL="https://github.com/dsh-tauri/deepseek-harness-desktop/releases/download/v$VERSION/Deepseek.Harness.Desktop_${VERSION}_$arch.deb"
fi

install_pkgurl
