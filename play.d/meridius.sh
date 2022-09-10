#!/bin/sh

PKGNAME=meridius
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Meridius — music player for VK"

. $(dirname $0)/common.sh

URL=$(epm tool eget --list --latest https://github.com/PurpleHorrorRus/Meridius/releases "$PKGNAME-*.tar.gz") || fatal "Can't get package URL"
epm install $URL
