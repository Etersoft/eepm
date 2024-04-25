#!/bin/sh

PKGNAME=NotepadNext
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="A cross-platform, reimplementation of Notepad++"
URL="https://github.com/dail8859/NotepadNext"

. $(dirname $0)/common.sh

PKGURL=$(eget --list --latest https://github.com/dail8859/NotepadNext/releases "*.AppImage")

install_pkgurl
