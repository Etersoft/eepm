#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=anydesk

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "Install AnyDesk from the official site" && exit

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

#if [ "$($DISTRVENDOR -d)" = "ALTLinux" ] ; then
#    epm install https://zoom.us/client/latest/zoom_$arch.rpm
#    exit
#fi

# https://download.anydesk.com/linux/anydesk_6.0.1-1_x86_64.rpm?
PKG="https://download.anydesk.com/linux/$(epm print constructname $PKGNAME "6.0.1-1" $arch "" "_")"

# we have workaround for their postinstall script, so always repack rpm package
repack=''
[ "$($DISTRVENDOR -p)" = "deb" ] || repack='--repack'

epm $repack install "$PKG"
