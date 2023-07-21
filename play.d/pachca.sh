#!/bin/sh

PKGNAME=pachca
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Корпоративный мессенджер Пачка с официального сайта"
VERSION="$2"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"
file="${PKGNAME}_${VERSION}_$arch.deb"

PKGURL=$(epm tool eget --list --latest https://github.com/pachca/pachca-desktop/releases $file) || fatal "Can't get package URL"

epm install "$PKGURL"

