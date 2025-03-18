#!/bin/sh

PKGNAME=wasistlos
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='An unofficial WhatsApp desktop application (from the repository if the package is there, or from the official site)'
URL="https://github.com/xeco23/WasIstLos"

. $(dirname $0)/common.sh

if epm install $PKGNAME ; then
    exit 0
fi

arch=x86_64
PKGURL=$(eget --list --latest https://github.com/xeco23/WasIstLos/releases/download "$PKGNAME-$VERSION-$arch.AppImage")

install_pkgurl

