#!/bin/sh

DESCRIPTION="Brave browser from the official site"

PKGNAME=brave-browser
SUPPORTEDARCHES="x86_64"
if [ "$2" = "beta" ] || epm installed $PKGNAME-beta ; then
    PKGNAME=$PKGNAME-beta
fi
if [ "$2" = "nightly" ] || epm installed $PKGNAME-nightly ; then
    PKGNAME=$PKGNAME-nightly
fi

. $(dirname $0)/common.sh



arch=x86_64
pkgtype=rpm
repack=''
# we have workaround for their postinstall script, so always repack rpm package
[ "$($DISTRVENDOR -p)" = "deb" ] || repack='--repack'

PKG=$(epm tool eget --list --latest https://github.com/brave/brave-browser/releases "$PKGNAME-[[:digit:]]*.$arch.$pkgtype") || fatal "Can't get package URL"

epm $repack install "$PKG"
