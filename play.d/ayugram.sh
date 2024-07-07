#!/bin/sh

PKGNAME=ayugram
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Desktop Telegram client with good customization and Ghost mode"
URL="https://github.com/AyuGram/AyuGramDesktop"
. $(dirname $0)/common.sh

PKGURL=$(eget --list --latest https://github.com/nevazno00/AyuGramDesktop-Linux-Binary/releases "AyuGram-$VERSION")

install_pack_pkgurl

