#!/bin/sh

PKGNAME=obs-linuxbrowser
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Portable version of OBS linux browser"
URL="https://github.com/bazukas/obs-linuxbrowser/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/bazukas/obs-linuxbrowser/" ".*.tgz")
else
    PKGURL="https://github.com/bazukas/obs-linuxbrowser/releases/download/0.6.1/linuxbrowser0.6.1-obs23.0.2-64bit.tgz"
fi

install_pack_pkgurl
