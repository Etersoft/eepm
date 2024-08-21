#!/bin/sh

PKGNAME=wine
SUPPORTEDARCHES="x86_64 x86"
DESCRIPTION='Wine 32/64 from the repo'
VERSION="$2"
TIPS="Run epm play wine=wine-vanilla to install wine-vanilla package"

MAIN=wine
#PKGCOMMON="wine-mono wine-gecko winetricks"
# wine-full and wine require needed versions of these common packages
PKGCOMMON=""

[ -n "$VERSION" ] && [ "$VERSION" != "*" ] && MAIN="$VERSION"
VERSION=""

if [ "$MAIN" = "wine-etersoft" ] ; then
    PKGCOMMON="wine-etersoft-mono wine-etersoft-gecko wine-etersoft-winetricks"
    PKGNAMES="wine-etersoft"
    PKGNAMES32="wine32-etersoft"
fi

# FIXME: wrong epm
if [ "$1" = "--remove" ] ; then
    epm remove $(epm qp $MAIN-)
    epm remove $PKGCOMMON
    exit
fi

. $(dirname $0)/common.sh

vendor="$(epm print info -s)"
arch="$(epm print info -a)"

if [ "$vendor" != "alt" ] ; then
    # Устанавливаем wine
    epm install $MAIN || exit

    case $arch in
        x86_64)
            # Доставляем пропущенные модули (подпакеты) для установленных 64-битных
            epm prescription i586-fix
            ;;
        esac
    exit
fi


ONLY32=''
[ "$3" = "--only-i586" ] && ONLY32=1 && shift

if [ "$MAIN" != "wine-etersoft" ] ; then

# do some magic: if winetricks more than 20210206, we have new wine package naming
epm install winetricks || exit 1
WTVER="$(epm print version for package winetricks)"
if [ "$(epm print compare package version "$WTVER" "20210206")" = "1" ] ; then
    PKGNAMES="$MAIN-full $MAIN-common"
    PKGNAMES32="i586-$MAIN"
else
    # old naming scheme
    PKGNAMES="$MAIN lib$MAIN lib$MAIN-gl lib$MAIN-twain"
    PKGNAMES32="i586-$MAIN i586-lib$MAIN i586-lib$MAIN-gl i586-lib$MAIN-twain"
    echo "We recommend ask about more new wine from your vendor."
fi

fi

if [ "$arch" = "x86" ] ; then
    PKGNAMES="$PKGNAMES $PKGCOMMON"
    epm install $PKGNAMES || exit
    exit
fi

if [ "$arch" = "x86_64" ] && [ -n "$ONLY32" ] ; then
    PKGNAMES="$PKGNAMES32 $PKGCOMMON"
    epm install $PKGNAMES || exit
    # Доставляем пропущенные модули (подпакеты) для установленных 64-битных
    epm prescription i586-fix
    exit
fi

if [ "$arch" = "x86_64" ] ; then
    PKGNAMES="$PKGNAMES $PKGCOMMON"
    epm install $PKGNAMES || exit
    # for non wow64 packages install 32 bit part
    if ! epm ql $MAIN | grep -q "/i386-windows/" ; then
        epm install $PKGNAMES32 || exit
        # Доставляем пропущенные модули (подпакеты) для установленных 64-битных
        epm prescription i586-fix
    fi
    exit
fi

echo "Arch $arch is not yet supported" && exit 1

# TODO:
# epm policy $MAIN-gl 2>/dev/null >/dev/null || OLD wine packaging name scheme
