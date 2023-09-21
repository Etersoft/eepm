#!/bin/sh

PKGNAME="far2l-portable"
SUPPORTEDARCHES="x86_64"
DESCRIPTION="FAR2L Portable from the official site"

. $(dirname $0)/common.sh

PKGURL=$(epm tool eget --list --latest https://github.com/spvkgn/far2l-portable/releases "far2l_x86_64.AppImage.tar")
[ -n "$PKGURL" ] || fatal "Can't get package URL"

epm --install pack $PKGNAME "$PKGURL"
