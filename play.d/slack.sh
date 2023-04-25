#!/bin/sh

PKGNAME=slack
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Slack from the official site'

. $(dirname $0)/common.sh

arch=x86_64
pkgtype=rpm

PKGMASK="$(epm print constructname $PKGNAME "$VERSION" $arch $pkgtype)"
PKG="$(epm tool eget --list --latest https://slack.com/downloads/instructions/fedora $PKGMASK)" || fatal "Can't get package URL"
[ -n "$PKG" ] || fatal "Can't get package URL"

epm install --repack "$PKG"
