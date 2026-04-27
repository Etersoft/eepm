#!/bin/sh

PKGNAME=AniLibrix
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Anilibria desktop anime cinema for any of your computers"
URL="https://github.com/pavloniym/anilibrix"

. $(dirname $0)/common.sh

PKGURL=$(get_github_url "https://github.com/pavloniym/anilibrix/" "AniLibrix-linux-x86_64-$VERSION.AppImage")

install_pkgurl