#!/bin/sh

PKGNAME=sidequest
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='The SideQuest desktop application'
URL="https://sidequestvr.com/"

. $(dirname $0)/common.sh

PKGURL=$(epm tool eget --list --latest "https://github.com/SideQuestVR/SideQuest/releases/" "*.tar.xz") || fatal "Can't get package URL"

epm pack --install $PKGNAME "$PKGURL"
