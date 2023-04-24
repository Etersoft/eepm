#!/bin/sh

PKGNAME=steam-launcher
SUPPORTEDARCHES="x86_64"
DESCRIPTION='Steam Launcher (from the repository if the package is there, or from the official site)'

[ "$(epm print info -s)" = "alt" ] && REPOPKGNAME=i586-steam || REPOPKGNAME=steam

epm installed $REPOPKGNAME && PKGNAME=$REPOPKGNAME

. $(dirname $0)/common.sh

res=0
if ! epm install $REPOPKGNAME ; then
    PKGURL="https://cdn.akamai.steamstatic.com/client/installer/steam.deb"
    epm install $PKGURL
    res=$?
fi

epm play i586-fix

exit $res
