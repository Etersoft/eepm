#!/bin/sh

PKGNAME=cadoodle
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="A drag-and-drop CAD package for beginners from the official site"
URL="https://cadoodlecad.com/"

. $(dirname $0)/common.sh

arch="$(epm print info -a)"
case "$arch" in
    aarch64)
        arch=arm64
        ;;
esac

if [ "$VERSION" = "*" ] ; then
    VERSION=$(get_github_tag https://github.com/CommonWealthRobotics/CaDoodle)
fi

PKGURL="https://github.com/CommonWealthRobotics/CaDoodle/releases/download/$VERSION/CaDoodle-Linux-$arch.deb"

install_pkgurl
