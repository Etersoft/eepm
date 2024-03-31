#!/bin/sh

PKGNAME=MyTonWallet
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="MyTonWallet from the official site"
URL="https://mytonwallet.app/"

. $(dirname $0)/common.sh

PKGURL=$(eget --list --latest https://github.com/mytonwalletorg/mytonwallet/releases "MyTonWallet-x86_64.AppImage") || fatal "Can't get package URL"

install_pkgurl
