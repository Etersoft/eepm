#!/bin/sh

PKGNAME=notepad-next
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="A cross-platform, reimplementation of Notepad++"
URL="https://github.com/dail8859/NotepadNext"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL=$(eget --list --latest https://github.com/dail8859/NotepadNext/releases "*.AppImage")

install_pack_pkgurl
