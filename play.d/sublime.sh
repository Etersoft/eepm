#!/bin/sh

PKGNAME=sublime-text
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='Sublime Text 4 from the official site'
URL="https://www.sublimetext.com/"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        arch=x64
        ;;
    aarch64)
        arch=arm64
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

PKGURL=$(eget --list --latest https://www.sublimetext.com/download_thanks "sublime_text_build_${VERSION}_$arch.tar.xz") || fatal "Can't get package URL"

install_pack_pkgurl

echo
echo "NOTE: Sublime Text 4 is a proprietary software. We recommend to use open source editors: Codium, VS Code, Atom."
