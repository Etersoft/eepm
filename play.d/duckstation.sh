#!/bin/sh

PKGNAME=duckstation
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="DuckStation is an simulator/emulator of the Sony PlayStation(TM) from the official site"
URL="https://github.com/stenzek/duckstation/releases"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL=$(get_github_version "https://github.com/stenzek/duckstation" "DuckStation-x64.AppImage")

install_pack_pkgurl
