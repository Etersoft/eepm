#!/bin/sh

PKGNAME=MyTonWallet
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="MyTonWallet from the official site"
URL="https://mytonwallet.app/"

. $(dirname $0)/common.sh

PKGURL=$(eget --list --latest https://github.com/mytonwalletorg/mytonwallet/releases "MyTonWallet-x86_64.AppImage")

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/mytonwalletorg/mytonwallet/" "MyTonWallet-x86_64.AppImage")
else
    PKGURL="https://github.com/mytonwalletorg/mytonwallet/releases/download/v$VERSION/MyTonWallet-x86_64.AppImage"
fi

install_pkgurl
