#!/bin/sh

PKGNAME=duplicati
VERSION="$2"
DESCRIPTION="Duplicati from the official site"

. $(dirname $0)/common.sh

warn_version_is_not_supported

pkgtype="$(epm print info -p)"

# we have workaround for their postinstall script, so always repack rpm package
[ "$pkgtype" = "deb" ] || repack='--repack'

#PKG=$(epm tool eget --list --latest https://www.duplicati.com/download "duplicati-*$pkgtype") || fatal "Can't get package URL"
PKG=$(epm tool eget -O /dev/stdout https://updates.duplicati.com/beta/latest-installers.js | grep -i -o -E '"url": "(.+)"' | cut -d'"' -f4 | grep "duplicati.*$pkgtype")

epm install $repack "$PKG"
