#!/bin/sh

BASEPKGNAME=brave-browser
SUPPORTEDARCHES="x86_64"
PRODUCTALT="'' beta nightly dev"
VERSION="$2"
DESCRIPTION="Brave browser from the official site"

. $(dirname $0)/common.sh

repack=''
# we have workaround for their postinstall script, so always repack rpm package
[ "$(epm print info -p)" = "deb" ] || repack='--repack'

# brave-browser-beta-1.51.105-1.x86_64.rpm
# brave-browser-beta_1.51.105_amd64.deb

PKGURL=$(epm tool eget --list --latest https://github.com/brave/brave-browser/releases "$(epm print constructname $PKGNAME "$VERSION")")

if [ -z "$PKGURL" ] ; then
    # force use beta if can't get stable version
    if [ "$PKGNAME" = "$BASEPKGNAME" ] ; then
        TOREMOVEPKG=$PKGNAME
        PKGNAME=$BASEPKGNAME-beta
        PKGURL=$(epm tool eget --list --latest https://github.com/brave/brave-browser/releases "$(epm print constructname $PKGNAME "$VERSION")")
        [ -n "$PKGURL" ] || fatal "Can't get package URL"

        echo "Force switching from $TOREMOVEPKG to $PKGNAME ... "
        epm installed $TOREMOVEPKG && epm remove $TOREMOVEPKG
    else
        fatal "Can't get package URL for $PKGNAME-$VERSION"
    fi
fi

epm $repack install "$PKGURL"
