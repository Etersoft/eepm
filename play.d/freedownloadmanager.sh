#!/bin/sh

PKGNAME=freedownloadmanager
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Powerful modern download accelerator and organizer"
URL="https://www.freedownloadmanager.org/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="$(eget --list "https://www.freedownloadmanager.org/ru/download-fdm-for-linux.htm" "freedownloadmanager.deb" | head -n 1)"

install_pkgurl
