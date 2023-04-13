#!/bin/sh

PKGNAME=Todoist
SUPPORTEDARCHES="x86_64"
DESCRIPTION='Todoist client application from the official site'

. $(dirname $0)/common.sh


epm install https://todoist.com/linux_app/appimage

