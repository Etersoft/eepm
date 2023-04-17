#!/bin/sh

PKGNAME=SweetHome3D
SUPPORTEDARCHES="x86_64 x86"
DESCRIPTION=''

. $(dirname $0)/common.sh


arch="$(epm print info -a)"
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
#VERSION=6.6
#PKGURL="http://download.sourceforge.net/project/sweethome3d/SweetHome3D/SweetHome3D-$VERSION/SweetHome3D-$VERSION-linux-$arch.tgz"

# http://sourceforge.net/projects/sweethome3d/files/SweetHome3D/SweetHome3D-7.1/SweetHome3D-7.1-linux-x86.tgz/download
URL="$(eget -4 --list --latest https://www.sweethome3d.com/download.jsp SweetHome3D-*-linux-$arch.tgz/download)"
PKGURL="$(echo "$URL" | sed -e "s|http://sourceforge.net/projects/sweethome3d/files|http://download.sourceforge.net/project/sweethome3d|" -e 's|/download$||' )"

epm install "$PKGURL"
