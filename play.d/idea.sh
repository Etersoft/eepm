#!/bin/sh

PKGNAME=idea
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="JetBrains IntelliJ IDEA - The Leading Java and Kotlin IDE from the official site"
URL="https://www.jetbrains.com/idea/"

. $(dirname $0)/common-jetbrains.sh

PKGURL="$(get_jetbrains_pkgurl IIU idea)"

install_pkgurl
