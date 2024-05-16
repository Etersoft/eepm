#!/bin/sh

PKGNAME=AniLibrix-linux
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Anilibria desktop anime cinema for any of your computers"
URL="https://github.com/pavloniym/anilibrix"

. $(dirname $0)/common.sh

PKGURL=$(eget --list --latest https://github.com/pavloniym/anilibrix/releases "AniLibrix-linux-x86_64-$VERSION.AppImage")

install_pkgurl