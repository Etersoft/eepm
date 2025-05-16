#!/bin/sh

PKGNAME=vkteams
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="VK Teams for Linux from the official site"
URL="https://biz.mail.ru/teams"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://vkteams-www.hb.bizmrg.com/linux/x64/vkteams.deb"

install_pkgurl
