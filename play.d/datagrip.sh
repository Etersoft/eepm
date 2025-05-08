#!/bin/sh

PKGNAME=datagrip
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="DataGrip - A powerful cross-platform tool for relational and NoSQL databases"
URL="https://www.jetbrains.com/datagrip/"

. $(dirname $0)/common-jetbrains.sh

PKGURL="$(get_jetbrains_pkgurl DG datagrip)"

install_pkgurl
