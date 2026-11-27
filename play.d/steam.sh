#!/bin/sh

PKGNAME=steam-launcher
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Steam Launcher (from the repository if the package is there, or from the official site)'
URL="https://store.steampowered.com/about"

[ "$(epm print info -s)" = "alt" ] && REPOPKGNAME=i586-steam || REPOPKGNAME=steam

epm installed $REPOPKGNAME && PKGNAME=$REPOPKGNAME

. $(dirname $0)/common.sh

warn_version_is_not_supported

if [ "$(epm print info -s)" = "alt" ] ; then
    [ -z "$print_url" ] || fatal "--print-url is not supported for steam from the system repository."
    epm install $REPOPKGNAME || exit
    epm play i586-fix
    exit
fi

if epm status --installable $REPOPKGNAME ; then
    [ -z "$print_url" ] || fatal "--print-url is not supported for steam from the system repository."
    epm install $REPOPKGNAME || exit
else
    PKGURL="https://cdn.akamai.steamstatic.com/client/installer/steam.deb"
    if [ -n "$print_url" ] ; then
        echo "$PKGURL"
        exit 0
    fi
    epm install $PKGURL || exit

    if [ "$(epm print info -s)" = "alt" ] ; then
        # https://bugzilla.altlinux.org/46110
        epm install --skip-installed lsof i586-libcurl
    fi

fi

epm play i586-fix

