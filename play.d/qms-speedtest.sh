#!/bin/sh

PKGNAME=qms-speedtest
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="QMS speedtest - internet connection speed and quality testing tool"
URL="https://www.qms.ru/applications/linux"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://lib.qms.ru/bin/linux/qms_lib.zip"

install_pack_pkgurl
