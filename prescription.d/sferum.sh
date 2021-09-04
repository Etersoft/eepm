#!/bin/sh -x

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=sferum

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "Sferum for Linux from the official site" && exit

arch=$($DISTRVENDOR --distro-arch)
case $arch in
    x86_64|amd64)
        arch=$arch ;;
    i686|i386)
        arch=$arch ;;
    i586)
        arch=i686 ;;
    *)
        fatal "Unsupported arch $arch for $($DISTRVENDOR -d)"
esac

repack=''
[ "$($DISTRVENDOR -d)" = "ALTLinux" ] && repack='--repack'

#https://st.mycdn.me/static/sferum/latest/sferum-i386.deb
#https://st.mycdn.me/static/sferum/latest/sferum-amd64.deb
#https://st.mycdn.me/static/sferum/latest/sferum-i686.rpm
#https://st.mycdn.me/static/sferum/latest/sferum-x86_64.rpm

# can't use constructname due '-' before arch
#epm install "https://st.mycdn.me/static/sferum/latest/$(epm print constructname $PKGNAME '' $arch '' '-')"
epm $repack install "https://st.mycdn.me/static/sferum/latest/$PKGNAME-$arch.$($DISTRVENDOR -p)"
