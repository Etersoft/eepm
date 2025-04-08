#!/bin/sh

PKGNAME=cursor
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="The AI-first Code Editor"
URL="https://cursor.sh/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://downloads.cursor.com/production/1d623c4cc1d3bb6e0fe4f1d5434b47b958b05876/linux/x64/Cursor-0.48.7-x86_64.AppImage"

install_pkgurl
