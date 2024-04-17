#!/bin/sh

PKGNAME=radicle
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Radicle is a sovereign code forge built on Git.'
URL="https://radicle.xyz/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

VERSION=$(eget -q -O- "https://files.radicle.xyz/latest/version.json" | epm tool json -b | grep version |  awk 'gsub(/"/, "", $2) {print $2}')
[ -n "$VERSION" ] || fatal "Can't get version"

PKGURL="https://files.radicle.xyz/latest/x86_64-unknown-linux-musl/radicle-x86_64-unknown-linux-musl.tar.gz"

install_pack_pkgurl $VERSION
