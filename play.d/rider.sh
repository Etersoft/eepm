#!/bin/sh

PKGNAME=JetBrains.Rider
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Rider - A cross-platform IDE for .NET and game dev from the official site"
URL="https://www.jetbrains.com/rider/"

. $(dirname $0)/common-jetbrains.sh
PKGURL="$(get_jetbrains_pkgurl RD rider)"

install_pkgurl
