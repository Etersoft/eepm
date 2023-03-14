#!/bin/sh

DESCRIPTION="Brave browser from the official site"

PKGNAME=brave-browser
BASEPKGNAME=brave-browser
SUPPORTEDARCHES="x86_64"
PRODUCTALT="'' beta nightly dev"

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
[ "$(epm print info -p)" = "deb" ] || repack='--repack'

PKG=$(epm tool eget --list --latest https://github.com/brave/brave-browser/releases "$PKGNAME-[[:digit:]]*.$arch.$pkgtype")

if [ -z "$PKG" ] ; then
    # force use beta
    if [ "$PKGNAME" = "$BASEPKGNAME" ] ; then
        TOREMOVEPKG=$PKGNAME
        # if there is no stable release, switch to beta
        PKGNAME=$BASEPKGNAME-beta
        PKG=$(epm tool eget --list --latest https://github.com/brave/brave-browser/releases "$PKGNAME-[[:digit:]]*.$arch.$pkgtype")
        [ -n "$PKG" ] || fatal "Can't get package URL"

        echo "Force switching from $TOREMOVEPKG to $PKGNAME ... "
        epm remove $TOREMOVEPKG
    else
        fatal "Can't get package URL"
    fi
fi

epm $repack install "$PKG"
