#!/bin/sh

PKGNAME=WebStorm
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="WebStorm - The smartest JavaScript IDE from the official site"
URL="https://www.jetbrains.com/webstorm/"

. $(dirname $0)/common-jetbrains.sh

PKGURL="$(get_jetbrains_pkgurl WS webstorm)"

install_pkgurl
