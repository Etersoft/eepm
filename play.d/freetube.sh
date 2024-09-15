#!/bin/sh

PKGNAME=freetube
SUPPORTEDARCHES="x86_64 armhf aarch64"
VERSION="$2"
DESCRIPTION='The Private YouTube Client'
URL="https://freetubeapp.io/"

. $(dirname $0)/common.sh

case "$(epm print info -a)" in
    aarch64)
        arch="arm64" ;;
    armhf)
        arch="armv7l" ;;
    x86_64)
        arch="amd64" ;;
esac

PKGURL=$(eget --list --latest https://github.com/FreeTubeApp/FreeTube/releases "freetube*${VERSION}*${arch}.deb")

install_pkgurl
