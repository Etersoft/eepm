#!/bin/sh

PKGNAME=sidequest
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='The SideQuest desktop application'
URL="https://sidequestvr.com/"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/SideQuestVR/SideQuest/" "SideQuest-.$VERSION.tar.xz")
else
    PKGURL="https://github.com/SideQuestVR/SideQuest/releases/download/v$VERSION/SideQuest-$VERSION.tar.xz"
fi

install_pack_pkgurl
