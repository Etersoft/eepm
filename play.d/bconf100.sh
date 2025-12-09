#!/bin/sh

PKGNAME=bconf100
VERSION="$2"
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Программа конфигурирования контроллера БАЗИС-100 from the official site"
URL="https://ecoresurs.ru/support/uploads/programms/bconf100/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="$(eget --list --latest https://ecoresurs.ru/support/uploads/programms/bconf100/ "${PKGNAME}_${VERSION}_all.deb" )"

install_pkgurl
