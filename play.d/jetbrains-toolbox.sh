#!/bin/sh

PKGNAME=jetbrains-toolbox
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="JetBrains Toolbox App from the official site"
URL="https://www.jetbrains.com/toolbox/"

. $(dirname $0)/common-jetbrains.sh

PKGURL="$(get_jetbrains_pkgurl TBA toolbox)"

install_pack_pkgurl
