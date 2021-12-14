#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=SweetHome3D

arch="$($DISTRVENDOR -a)"
case "$arch" in
    x86_64)
        arch=x64
        ;;
    x86)
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    exit
fi

[ "$1" != "--run" ] && exit #echo "Sweet Home 3D from the official site" && exit

# TODO: get url from https://sourceforge.net/projects/sweethome3d/best_release.json (is it client system dependend??)
# see get_github_urls in eget
VERSION=6.6
PKG="http://download.sourceforge.net/project/sweethome3d/SweetHome3D/SweetHome3D-$VERSION/SweetHome3D-$VERSION-linux-$arch.tgz"

epm --repack install "$PKG"
