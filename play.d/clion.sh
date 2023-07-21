#!/bin/sh

PKGNAME=CLion
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="CLion - A cross-platform IDE for C and C++ from the official site"
URL="https://www.jetbrains.com/clion/"

. $(dirname $0)/common-jetbrains.sh

PKGURL="$(get_jetbrains_pkgurl CL cpp)"

epm install $PKGURL
