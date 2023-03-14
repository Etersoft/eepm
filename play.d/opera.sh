#!/bin/sh

DESCRIPTION="Opera browser from the official site"

PRODUCTALT="stable beta developer"

BRANCH=stable
if [ "$2" = "beta" ] || epm installed opera-beta ; then
    BRANCH=beta
fi
if [ "$2" = "developer" ] || epm installed opera-developer ; then
    BRANCH=developer
fi
PKGNAME=opera-$BRANCH

SUPPORTEDARCHES="x86_64"

. $(dirname $0)/common.sh

arch="amd64"

epm play chromium-codecs-ffmpeg-extra || fatal

# Stable branch here for deb too
if [ "$BRANCH" = "stable" ] ; then

URL="https://ftp.opera.com/pub/opera/desktop/"
PKGBASEURL="$(epm tool eget --list --latest $URL/*)"linux

if ! check_url_is_accessible $PKGBASEURL ; then
    PKGBASEURL="$(epm tool eget --list --second-latest $URL/*)"linux
    check_url_is_accessible $PKGBASEURL || fatal "Can't find Opera package for Linux at $URL"
fi

PKGURL="$(epm tool eget --list --latest $PKGBASEURL "$(epm print constructname $PKGNAME "*" $arch deb)")" || fatal #"
epm install "$PKGURL" || fatal
exit

else

# they put all branch here (rpm only): https://rpm.opera.com/rpm/
[ "$(epm print info -s)" = "alt" ] && repack='--repack' || repack=''
epm install $repack https://rpm.opera.com/rpm/opera_$BRANCH-*-linux-release-x64-signed.rpm

fi
