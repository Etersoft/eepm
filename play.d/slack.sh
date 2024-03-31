#!/bin/sh

PKGNAME=slack
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Slack from the official site'
URL="https://slack.com"

. $(dirname $0)/common.sh

arch=x86_64
pkgtype=rpm

mask="$(epm print constructname $PKGNAME "$VERSION" $arch $pkgtype)"
PKGURL="$(eget --list --latest https://slack.com/downloads/instructions/fedora "$mask")" || fatal "Can't get package URL"
[ -n "$PKGURL" ] || fatal "Can't get package URL"

epm install --repack "$PKGURL"
