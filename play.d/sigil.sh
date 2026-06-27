#!/bin/sh

PKGNAME=Sigil
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Sigil is a multi-platform EPUB ebook editor'
URL="https://github.com/Sigil-Ebook/Sigil"

. $(dirname $0)/common.sh

PKGURL=$(get_github_url "https://github.com/Sigil-Ebook/Sigil" "Sigil-${VERSION}-x86_64.AppImage")

install_pkgurl
