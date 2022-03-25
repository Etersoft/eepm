#!/bin/sh

PKGNAME=brave-browser
DESCRIPTION="Brave browser from the official site"

. $(dirname $0)/common.sh


[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

arch=x86_64
pkgtype=rpm
repack=''
# we have workaround for their postinstall script, so always repack rpm package
[ "$($DISTRVENDOR -p)" = "deb" ] || repack='--repack'

PKG=$($EGET --list --latest https://github.com/brave/brave-browser/releases "$PKGNAME-*.$arch.$pkgtype") || fatal "Can't get package URL"

epm $repack install "$PKG"
