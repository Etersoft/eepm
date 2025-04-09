#!/bin/sh

PKGNAME=radicle-httpd
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Radicle is a sovereign code forge built on Git.'
URL="https://radicle.xyz/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

VERSION="$(get_json_value "https://files.radicle.xyz/releases/radicle-httpd/latest/radicle-httpd.json" "version")"

[ -n "$VERSION" ] || fatal "Can't get version"

PKGURL="https://files.radicle.xyz/releases/radicle-httpd/latest/radicle-httpd-$VERSION-x86_64-unknown-linux-musl.tar.xz"

install_pack_pkgurl $VERSION
