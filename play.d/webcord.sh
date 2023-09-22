#!/bin/sh

PKGNAME=WebCord
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="A Discord and Spacebar client implemented directly without Discord API from the official github"

. $(dirname $0)/common.sh

pkgtype=AppImage

PKGURL=$(epm tool eget --list --latest https://github.com/SpacingBat3/WebCord/releases "WebCord-$VERSION-x64.$pkgtype")
[ -n "$PKGURL" ] || fatal "Can't get package URL"

epm install "$PKGURL"
