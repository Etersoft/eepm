#!/bin/sh

PKGNAME=freetube
SUPPORTEDARCHES="x86_64 armhf aarch64"
VERSION="$2"
DESCRIPTION='The Private YouTube Client'
URL="https://freetubeapp.io/"

. $(dirname $0)/common.sh

arch="$(epm print info --debian-arch)"

PKGURL=$(eget --list --latest https://github.com/FreeTubeApp/FreeTube/releases "freetube*${VERSION}*${arch}.deb")

install_pkgurl
