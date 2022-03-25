#!/bin/sh

PKGNAME=sferum
DESCRIPTION="Sferum for Linux from the official site"

. $(dirname $0)/common.sh


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
