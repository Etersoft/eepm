#!/bin/sh

PKGNAME=svodly
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Svod.li (svodly) - personal and small business finance accounting from the official site"
URL="https://svodly.ru/download"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    # Tauri updater manifest: "version": "1.0.42"
    VERSION="$(get_json_value "https://updates.svodly.ru/stable/linux-x86_64/0.0.0/latest.json" "version")"
    [ -n "$VERSION" ] || fatal "Can't get latest version."
fi

# https://updates.svodly.ru/releases/1.0.42/Svodly_1.0.42_amd64.deb
PKGURL="https://updates.svodly.ru/releases/$VERSION/Svodly_${VERSION}_amd64.deb"

install_pkgurl
