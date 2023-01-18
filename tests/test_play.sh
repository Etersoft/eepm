#!/bin/bash

# TODO: use epm from the sources

fatal()
{
    exit 1
}

#set -e -x
#set -o pipefail

EPM=$(realpath $(dirname $0)/../bin/epm)


if [ "$1" == "--hasher" ] ; then
    shift
    B=''
    if [ "$1" = "-b" ] ; then
        shift
        B="-b $1"
        shift
    fi
    APP="$1"

    if [ "$APP" == "all" ] ; then
        $EPM play --list-all --short | while read app ; do
            $0 --hasher $B $app </dev/null || fatal
        done
        exit
    fi

    loginhsh -i -t -p epm $B -r true curl iputils eepm-repack apt-repo
    loginhsh -t -p epm $B -o

    HDIR=$(loginhsh -q -t -d -p epm $B)
    cp -afv ../* $HDIR/chroot/.in
    loginhsh -t -p epm $B -o -r "bash -x /.in/tests/test_play.sh --local $APP" || exit
    loginhsh -c -t -p epm $B
    exit
fi

if [ "$1" != "--local" ] ; then
    echo "Run with --hasher or --local to test all apps install"
    exit
fi

shift
SILENT=''
if [ "$1" == "--silent" ] ; then
    SILENT="$1"
    shift
fi
APP="$1"

echo "Check Internet connection ..."
cat /etc/resolv.conf
ping -c 1 ya.ru
ping -c 1 8.8.8.8
epm repo set sisyphus && epm repo change etersoft && epm update

$EPM --version
$EPM print info

if [ -n "$SILENT" ] ; then
    $EPM play --list-all --short | while read app ; do
        echo -n "Silent installing $app ... "
        $EPM --auto play $app </dev/null >/dev/null 2>/dev/null && echo -n "DONE" || { echo "ERROR" ; continue ; }
        echo -n "  Removing $app ... "
        $EPM --auto play --remove $app </dev/null >/dev/null 2>/dev/null && echo -n "DONE" || { echo "ERROR" ; continue ; }
    done
    exit
fi

if [ -n "$APP" ] ; then
    app="$APP"
    echo
    echo "Installing $app ... "
    $EPM --auto play --verbose $app </dev/null || exit
    echo "  Removing $app ... "
    $EPM --auto play --remove $app </dev/null
    exit
fi

$EPM play --list-all --short | while read app ; do
    echo
    echo "Installing $app ... "
    $EPM --auto play --verbose $app </dev/null || exit
    echo "  Removing $app ... "
    $EPM --auto play --remove $app </dev/null
done

exit
