#!/bin/sh

PKGNAME=Todoist-linux
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='Todoist client application from the official site'
URL="https://todoist.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://todoist.com/linux_app/appimage"

install_pkgurl
