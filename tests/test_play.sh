#!/bin/bash

fatal()
{
    exit 1
}

#set -e -x
#set -o pipefail

if [ "$1" == "--hasher" ] ; then
    shift
    B="$2" ; [ -n "$B" ] && B="-b $B"
    loginhsh -i -t -p epm $B -r true curl iputils alien
    loginhsh -t -p epm $B -o
#exit
    HDIR=$(loginhsh -q -t -d -p epm $B)
    cp -a ../* $HDIR/chroot/.in
    loginhsh -t -p epm $B -o -r 'bash -x /.in/tests/test_play.sh --local'
exit
#
    loginhsh -c -t -p epm $B
    exit
fi

if [ "$1" != "--local" ] ; then
    echo "Run with --hasher or --local to test all apps install"
    exit
fi

echo "Check Internet connection ..."
cat /etc/resolv.conf
ping -c ya.ru
ping -c 8.8.8.8


if [ "$1" == "--silent" ] ; then
    epm play --list-all --short | while read app ; do
        echo -n "Silent installing $app ... "
        epm play $app </dev/null >/dev/null 2>/dev/null && echo -n "DONE" || { echo "ERROR" ; continue ; }
        echo -n "  Removing $app ... "
        epm play --remove $app </dev/null >/dev/null 2>/dev/null && echo -n "DONE" || { echo "ERROR" ; continue ; }
    done
    exit
fi

epm play --list-all --short | while read app ; do
    echo
    echo "Installing $app ... "
    epm play $app </dev/null
    echo "  Removing $app ... "
    epm play --remove $app </dev/null
done
exit
