#!/bin/sh

PKGNAME=Todoist-linux
SUPPORTEDARCHES="x86_64"
DESCRIPTION='Todoist client application from the official site'
URL="https://todoist.com/"

. $(dirname $0)/common.sh

PKGURL="https://todoist.com/linux_app/appimage"

epm install $PKGURL
