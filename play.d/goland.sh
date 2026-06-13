#!/bin/sh

PKGNAME=goland
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="JetBrains GoLand CE — IDE for Go developers"
URL="https://www.jetbrains.com/go/"

. $(dirname $0)/common-jetbrains.sh

PKGURL="$(get_jetbrains_pkgurl GO go)"

install_pkgurl
