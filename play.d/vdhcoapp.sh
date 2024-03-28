#!/bin/sh

PKGNAME=net.downloadhelper.coapp.noffmpeg
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Video DownloadHelper Companion App 2"
URL="https://www.downloadhelper.net/w/CoApp-Installation"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"

mask="dhcoapp-noffmpeg-linux-$arch.deb"

PKGURL=$(eget --list --latest https://github.com/aclap-dev/vdhcoapp/releases/ $mask) || fatal "Can't get package URL"

repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

epm install $repack "$PKGURL"
