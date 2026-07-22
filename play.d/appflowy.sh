#!/bin/sh

PKGNAME=AppFlowy
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="AppFlowy - an open source Notion alternative"
URL="https://www.appflowy.io/"

. $(dirname $0)/common.sh

epm assure unsquashfs squashfs-tools || fatal

is_glibc_enough 2.32 || fatal "AppFlowy needs glibc 2.32 or newer."

PKGURL="$(get_github_url AppFlowy-IO/AppFlowy "AppFlowy-${VERSION}-linux-x86_64.AppImage")"

install_pkgurl
