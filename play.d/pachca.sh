#!/bin/sh

PKGNAME=pachca
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Корпоративный мессенджер Пачка с официального сайта"
URL="https://github.com/pachca/pachca-desktop"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"
file="${PKGNAME}_${VERSION}_$arch.deb"

PKGURL=$(eget --list --latest https://github.com/pachca/pachca-desktop/releases "$file") || fatal "Can't get package URL"

install_pkgurl

