#!/bin/sh

PKGNAME=PhpStorm
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="PhpStorm - The Lightning-Smart PHP IDE from the official site"
URL="https://www.jetbrains.com/phpstorm/"

. $(dirname $0)/common-jetbrains.sh

PKGURL="$(get_jetbrains_pkgurl PS webide)"

epm install $PKGURL
