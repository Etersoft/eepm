#!/bin/sh

PKGNAME=lossless-cut
SUPPORTEDARCHES="x86_64 aarch64 armhf"
VERSION="$2"
DESCRIPTION='The swiss army knife of lossless video/audio editing'
URL="https://github.com/mifi/lossless-cut"

. $(dirname $0)/common.sh

case "$(epm print info -a)" in
    x86_64)
        arch="x64" ;;
    aarch64)
        arch="arm64" ;;
    armhf)
        arch="armv7l" ;;
esac

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/mifi/lossless-cut/" "LosslessCut-linux-$arch.tar.bz2")
else
    PKGURL="https://github.com/mifi/lossless-cut/releases/download/v$VERSION/LosslessCut-linux-$arch.tar.bz2"
fi

install_pack_pkgurl

