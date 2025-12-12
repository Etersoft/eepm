#!/bin/sh

PKGNAME=pachca
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Корпоративный мессенджер Пачка с официального сайта"
URL="https://pachca.com/apps"

. $(dirname $0)/common.sh

#arch="$(epm print info --debian-arch)"
#file="${PKGNAME}_${VERSION}_$arch.deb"

#PKGURL=$(eget --list --latest https://github.com/pachca/pachca-desktop/releases "$file")
#PKGURL="https://install.pachca.com/linux/appImage/x64"
# deb keeps name pachca
PKGURL="https://install.pachca.com/linux/deb/x64"

install_pkgurl
