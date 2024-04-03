#!/bin/bash

# TODO: use epm from the sources

fatal()
{
    exit 1
}

#set -e -x
#set -o pipefail

EPM=$(realpath $(dirname $0)/../bin/epm)

ipfs=''
kubo=''

if [ "$1" == "--ipfs" ] ; then
    ipfs="--ipfs"
    kubo="kubo"
    shift
fi


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
            $0 $ipfs --hasher $B $app </dev/null || fatal
        done
        exit
    fi

    loginhsh -Y -i -t -p epm $B -r true curl iputils eepm-repack apt-repo $kubo
    loginhsh -Y -t -p epm $B -o

    HDIR=$(loginhsh -q -t -d -p epm $B)
    cp -afv ../* $HDIR/chroot/.in
    # install
    loginhsh -Y -t -p epm $B -o -r "bash -x /.in/tests/test_play.sh $ipfs --local $APP" || exit
    # login under root
    loginhsh -t -p epm $B -o
    # login under user
    loginhsh -Y -t -s -p epm $B
    # clean
    loginhsh -c -t -p epm $B
    exit
fi

if [ "$1" != "--local" ] ; then
    echo "Run with --hasher or --local to test all apps install"
    exit
fi

[ -n "$ipfs" ] && export EGET_IPFS_API=/ip4/91.232.225.49/tcp/5001

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
    $EPM play $ipfs --list-all --short | while read app ; do
        echo -n "Silent installing $app ... "
        $EPM --auto play $ipfs $app </dev/null >/dev/null 2>/dev/null && echo -n "DONE" || { echo "ERROR" ; continue ; }
        echo -n "  Removing $app ... "
        $EPM --auto play $ipfs --remove $app </dev/null >/dev/null 2>/dev/null && echo -n "DONE" || { echo "ERROR" ; continue ; }
    done
    exit
fi

if [ -n "$APP" ] ; then
    app="$APP"
    echo
    echo "Installing $app ... "
    $EPM --auto play --verbose $ipfs $app </dev/null || exit
    #bash
    #echo "  Removing $app ... "
    #$EPM --auto play $ipfs --remove $app </dev/null
    exit
fi

$EPM play --list-all --short | while read app ; do
    echo
    echo "Installing $app ... "
    $EPM --auto play --verbose $ipfs $app </dev/null || exit
    bash
    echo "  Removing $app ... "
    $EPM --auto play $ipfs --remove $app </dev/null
done

exit
