#!/bin/sh

PKGNAME=duckstation
SUPPORTEDARCHES="x86_64"
DESCRIPTION="DuckStation is an simulator/emulator of the Sony PlayStation(TM) from the official site"
URL="https://github.com/stenzek/duckstation/releases"

. $(dirname $0)/common.sh

file="DuckStation-x64.AppImage"

# TODO: preview, previous-latest
SELECTOR="latest"

PKGURL=$(epm tool eget --list https://github.com/stenzek/duckstation/releases $file | grep "/$SELECTOR/") || fatal "Can't get package URL"

epm pack --install "$PKGNAME" "$PKGURL"
