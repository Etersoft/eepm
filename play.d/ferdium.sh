#!/bin/sh

PKGNAME=Ferdium-linux
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Ferdium helps you organize how you use your favourite apps"
URL="https://ferdium.org/"
. $(dirname $0)/common.sh

# Ferdium-linux-7.1.2-nightly.3-arm64.deb
[ "$VERSION" = "*" ] && VERSION="[0-9]*[0-9].[0-9]"

pkgtype="$(epm print info -p)"
arch="$(epm print info --distro-arch)"

file="${PKGNAME}-${VERSION}-$arch.$pkgtype"

PKGURL=$(eget --list --latest https://github.com/ferdium/ferdium-app/releases "$file")

install_pack_pkgurl

