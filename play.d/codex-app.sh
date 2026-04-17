#!/bin/sh

PKGNAME=codex-app
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='OpenAI Codex Desktop app'
URL="https://github.com/Boria138/codex-app-linux"

. $(dirname $0)/common.sh


arch=x86_64
if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_url "https://github.com/Boria138/codex-app-linux" "codex-app-$VERSION-$arch.AppImage")
else
    PKGURL="https://github.com/Boria138/codex-app-linux/releases/download/$VERSION/codex-app-$VERSION-$arch.AppImage"
fi

install_pkgurl
