#!/bin/sh

PKGNAME=ideaIC
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="IntelliJ IDEA Community Edition - The Leading Java and Kotlin IDE from the official site"
URL="https://www.jetbrains.com/idea/"

. $(dirname $0)/common-jetbrains.sh

PKGURL="$(get_jetbrains_pkgurl IIC idea)"

install_pkgurl
