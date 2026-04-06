#!/bin/sh

PKGNAME=pycharm
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="PyCharm Professional — The Python IDE for Professional Developers (Trial)"
URL="https://www.jetbrains.com/ru-ru/pycharm/"

. $(dirname $0)/common-jetbrains.sh

PKGURL="$(get_jetbrains_pkgurl PCP python)"

install_pkgurl
