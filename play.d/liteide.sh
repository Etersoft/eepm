#!/bin/sh

PKGNAME=liteide
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION="LiteIDE is a simple, open source, cross-platform Go IDE. From the official site"
URL="https://github.com/visualfc/liteide"

. $(dirname $0)/common.sh

archbit="$(epm print info -b)"

PKGURL=$(eget --list --latest https://github.com/visualfc/liteide/releases "liteidex$VERSION.linux$archbit-qt5*-system.tar.gz") #"

install_pack_pkgurl
