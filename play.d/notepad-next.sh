#!/bin/sh

PKGNAME=NotepadNext
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="A cross-platform, reimplementation of Notepad++"
URL="https://github.com/dail8859/NotepadNext"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    PKGURL=$(get_github_version "https://github.com/dail8859/NotepadNext/" "NotepadNext-v.$VERSION-x86_64.AppImage")
else
    PKGURL="https://github.com/dail8859/NotepadNext/releases/download/v$VERSION/NotepadNext-v$VERSION-x86_64.AppImage"
fi

install_pkgurl
