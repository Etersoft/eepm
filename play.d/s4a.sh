#!/bin/sh

PKGNAME="S4A"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='A Scratch modification that allows for simple programming of the Arduino open source hardware platform'
URL="https://s4a.cat/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://s4a.cat/downloads/S4A16.deb"

install_pkgurl

