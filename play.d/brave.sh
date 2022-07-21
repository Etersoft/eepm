#!/bin/sh

DESCRIPTION="Brave browser from the official site"

PKGNAME=brave-browser
SUPPORTEDARCHES="x86_64"
PRODUCTALT="'' beta nightly"

for i in $PRODUCTALT ; do
    [ "$i" = "''" ] && continue
    if [ "$2" = "$i" ] || epm installed $PKGNAME-$i ; then
        PKGNAME=$PKGNAME-$i
        break
    fi
done

. $(dirname $0)/common.sh


arch=x86_64
pkgtype=rpm
repack=''
# we have workaround for their postinstall script, so always repack rpm package
[ "$($DISTRVENDOR -p)" = "deb" ] || repack='--repack'

PKG=$(epm tool eget --list --latest https://github.com/brave/brave-browser/releases "$PKGNAME-[[:digit:]]*.$arch.$pkgtype") || fatal "Can't get package URL"

epm $repack install "$PKG"
