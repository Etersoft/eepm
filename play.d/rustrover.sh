#!/bin/sh

PKGNAME=RustRover
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="JetBrains RustRover — IDE for Rust developers"
URL="https://www.jetbrains.com/rust/"

. $(dirname $0)/common-jetbrains.sh

PKGURL="$(get_jetbrains_pkgurl RR rustrover)"

install_pkgurl
