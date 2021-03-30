#!/bin/sh -x

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=code

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "Install Visual Studio Code from the official site" && exit

arch="$($DISTRVENDOR -a)"
case "$arch" in
    x86_64)
        arch=x64
        ;;
    armhf)
        ;;
    aarch64)
        arch=arm64
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac


pkgtype="$($DISTRVENDOR -p)"

# we have workaround for their postinstall script, so always repack rpm package
[ "$pkgtype" = "deb" ] || repack='--repack'

PKG=/tmp/$PKGNAME.$pkgtype
# TODO: wget does not support:  Content-Disposition: attachment; filename="code-1.52.1-1608137084.el7.x86_64.rpm"
$EGET -O $PKG "https://code.visualstudio.com/sha/download?build=stable&os=linux-$pkgtype-$arch" || fatal

epm install $repack "$PKG" || exit
rm -fv $PKG
