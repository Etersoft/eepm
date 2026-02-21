#!/bin/sh

PKGNAME=vidbee
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Download videos from almost any website worldwide"
URL="https://vidbee.org"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"
PKGURL=$(get_github_url https://github.com/nexmoe/VidBee "vidbee_${VERSION}_$arch.deb")


install_pkgurl
