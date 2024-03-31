#!/bin/sh

PKGNAME=slack
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Slack from the official site'
URL="https://slack.com"

. $(dirname $0)/common.sh

arch=x86_64
pkgtype=rpm

# https://downloads.slack-edge.com/desktop-releases/linux/x64/4.37.94/slack-4.37.94-0.1.el8.x86_64.rpm
mask="$(epm print constructname $PKGNAME "$VERSION-[.09]*" $arch $pkgtype)"
PKGURL="$(eget --list --latest https://slack.com/downloads/instructions/fedora "$mask")" || fatal "Can't get package URL"

install_pkgurl
