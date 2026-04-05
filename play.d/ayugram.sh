#!/bin/sh

PKGNAME=ayugram-desktop
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Desktop Telegram client with good customization and Ghost mode"
URL="https://github.com/AyuGram/AyuGramDesktop"

. $(dirname $0)/common.sh

PKGURL=$(get_github_url "rsg245/ayugram-desktop-bin-arch" "ayugram-desktop-${VERSION}-*-x86_64.pkg.tar.zst")

install_pkgurl

