#!/bin/sh

PKGNAME=Rider
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Rider - A cross-platform IDE for .NET and game dev from the official site"
URL="https://www.jetbrains.com/clion/"

. $(dirname $0)/common-jetbrains.sh

# name for download
# FIXME: by some reason alien makes Rider from JetBrains.Rider
PKGNAME=JetBrains.Rider
PKGURL="$(get_jetbrains_pkgurl RD rider)"

install_pkgurl
