#!/bin/sh

PKGNAME=MAX
SUPPORTEDARCHES="x86_64"
DESCRIPTION='Быстрое и лёгкое приложение для общения и решения повседневных задач'
URL="https://max.ru/"

. $(dirname $0)/common.sh

PKGURL="https://download.max.ru/electron/MAX.AppImage"

install_pkgurl
