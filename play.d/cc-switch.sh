#!/bin/sh

PKGNAME=cc-switch
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION='CC-Switch — All-in-One assistant for Claude Code, Codex and Gemini CLI'
URL="https://github.com/farion1231/cc-switch"

. $(dirname $0)/common.sh

# Tauri desktop app (uses the system webkit2gtk, not bundled). Upstream ships
# clean deb/rpm/AppImage builds with no maintainer scripts, so no repack needed.

arch="$(epm print info -a)"
pkg="$(epm print info -p)"

case "$arch" in
    x86_64) filearch=x86_64 ;;
    aarch64) filearch=arm64 ;;
    *) fatal "Unsupported architecture: $arch" ;;
esac

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_github_tag $URL)"
fi
ver="${VERSION#v}"

PKGURL=$(get_github_url $URL "CC-Switch-v${ver}-Linux-${filearch}.$pkg") ||
    fatal "Can't get package URL for cc-switch $ver ($filearch.$pkg)"

install_pkgurl
