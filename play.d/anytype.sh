#!/bin/sh

PKGNAME=Anytype
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='The everything app for those who celebrate trust & autonomy'
URL="https://anytype.io/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="$(eget --list --latest https://download.anytype.io/ "*.AppImage")"

install_pkgurl

