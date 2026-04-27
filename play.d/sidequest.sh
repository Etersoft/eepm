#!/bin/sh

PKGNAME=sidequest
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='The SideQuest desktop application'
URL="https://sidequestvr.com/"

. $(dirname $0)/common.sh

PKGURL=$(get_github_url "https://github.com/SideQuestVR/SideQuest/" "SideQuest-$VERSION.tar.xz")

install_pack_pkgurl
