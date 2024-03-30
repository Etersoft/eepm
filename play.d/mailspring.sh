#!/bin/sh

PKGNAME=mailspring
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Mailspring - a beautiful, fast and fully open source mail client"
URL="https://www.getmailspring.com/"

. $(dirname $0)/common.sh


# https://github.com/Foundry376/Mailspring/releases/download/1.13.3/mailspring-1.13.3-amd64.deb
arch=amd64
pkgtype=deb

PKGURL=$(eget --list --latest https://github.com/Foundry376/Mailspring/releases/ "$PKGNAME*$VERSION*$arch.$pkgtype") || fatal "Can't get package URL"

epm install "$PKGURL"
