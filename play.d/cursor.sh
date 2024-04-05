#!/bin/sh

PKGNAME=cursor
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="The AI-first Code Editor"
URL="https://cursor.sh/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://download.cursor.sh/linux/appImage/x64"

install_pkgurl
