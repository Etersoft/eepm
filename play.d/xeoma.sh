#!/bin/sh

PKGNAME=xeoma
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Video surveillance with AI video analytics"
URL="https://felenasoft.com/xeoma/ru/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

VERSION=$(eget -q -O- "https://felenasoft.com/xeoma/en/changes/" | grep "Official version" | grep -o -m 1 "[0-9.]\+" | grep -o -m 1 "[0-9.]\+")
PKGURL="https://felenasoft.com/xeoma/downloads/latest/linux/xeoma_linux64.tgz"

install_pack_pkgurl $VERSION
