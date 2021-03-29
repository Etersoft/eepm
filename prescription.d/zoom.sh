#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=zoom

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "Install Zoom client from the official site" && exit

arch=$($DISTRVENDOR --distro-arch)
case $arch in
    x86_64|amd64)
        version=latest
        repack=''
        arch=$arch ;;
    i586|i386)
        version=5.4.53391.1108
        repack='--repack'
        arch=i686 ;;
    *)
        fatal "Unsupported arch $arch for $($DISTRVENDOR -d)"
esac

if [ "$($DISTRVENDOR -d)" = "ALTLinux" ] ; then
    epm install $repack https://zoom.us/client/$version/zoom_$arch.rpm
    exit
fi

# TODO: there are more complex distro dependent url
epm install "https://zoom.us/client/latest/zoom_$arch.$($DISTRVENDOR -p)"
