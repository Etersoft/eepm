#!/bin/sh

PKGNAME=google-chrome-stable
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="The popular and trusted web browser by Google (Stable Channel) from the official site"

. $(dirname $0)/common.sh


#arch=$(epm print info --distro-arch)
#pkgtype=$(epm print info -p)
repack=''
arch=amd64
pkgtype=deb

# we have workaround for their postinstall script, so always repack rpm package
[ "$(epm print info -p)" = "deb" ] || repack='--repack'

PKG="https://dl.google.com/linux/direct/google-chrome-stable_current_$arch.$pkgtype"

epm install $repack "$PKG"
