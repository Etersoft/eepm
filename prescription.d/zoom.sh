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
        arch=$arch ;;
    i586|i386)
        arch=$arch ;;
    *)
        fatal "Unsupported arch $arch for $($DISTRVENDOR -d)"
esac

if [ "$($DISTRVENDOR -d)" = "ALTLinux" ] ; then
    epm install https://zoom.us/client/latest/zoom_$arch.rpm
    exit
fi

# TODO: there are more complex distro dependent url
epm --noscripts install "https://zoom.us/client/latest/zoom_$arch.$($DISTRVENDOR -p)"
