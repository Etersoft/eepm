#!/bin/sh

PKGNAME=duplicati
DESCRIPTION="Duplicati from the official site"

. $(dirname $0)/common.sh

pkgtype="$($DISTRVENDOR -p)"

# we have workaround for their postinstall script, so always repack rpm package
[ "$pkgtype" = "deb" ] || repack='--repack'

#PKG=$($EGET --list --latest https://www.duplicati.com/download "duplicati-*$pkgtype") || fatal "Can't get package URL"
PKG=$($EGET -O /dev/stdout https://updates.duplicati.com/beta/latest-installers.js | grep -i -o -E '"url": "(.+)"' | cut -d'"' -f4 | grep "duplicati.*$pkgtype")

epm install $repack "$PKG"
