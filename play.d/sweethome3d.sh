#!/bin/sh

PKGNAME=SweetHome3D
DESCRIPTION=''

. $(dirname $0)/common.sh


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

# TODO: get url from https://sourceforge.net/projects/sweethome3d/best_release.json (is it client system dependend??)
# see get_github_urls in eget
VERSION=6.6
PKG="http://download.sourceforge.net/project/sweethome3d/SweetHome3D/SweetHome3D-$VERSION/SweetHome3D-$VERSION-linux-$arch.tgz"

epm --repack install "$PKG"
