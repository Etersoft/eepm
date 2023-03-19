#!/bin/sh

SUPPORTEDARCHES="x86_64"
PRODUCTALT="stable beta"
DESCRIPTION=''

BRANCH=stable
if [ "$2" = "beta" ] || epm installed yandex-browser-beta-codecs-ffmpeg-extra ; then
    BRANCH=beta
fi

BASEPKGNAME=yandex-browser-$BRANCH
PKGNAME=$BASEPKGNAME-codecs-ffmpeg-extra

. $(dirname $0)/common.sh

epm pack --install $PKGNAME
