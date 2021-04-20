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

VERSION=*
# el8 build contains libpangx inside
REL=*.el8
# we have workaround for their postinstall script, so always repack rpm package
repack=''
[ "$($DISTRVENDOR -p)" = "deb" ] && REL=1 || repack='--repack'

# https://download.anydesk.com/linux/anydesk-6.0.1-1.el8.x86_64.rpm
# https://download.anydesk.com/linux/anydesk_6.0.1-1_i386.deb
PKG="https://download.anydesk.com/linux/$(epm print constructname $PKGNAME "$VERSION-$REL" $arch)"

epm $repack install "$PKG"

echo
echo "Note: run
# serv anydesk on
to enable needed anydesk system service
"
