#!/bin/sh

PKGNAME=XPPenLinux
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="XP-Pen (Official) Linux utility"
URL="https://www.xp-pen.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://www.xp-pen.com/download/file.html?id=3561&pid=1179&ext=deb"

install_pkgurl
