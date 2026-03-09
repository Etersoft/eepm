#!/bin/sh

PKGNAME=satvision-smart-systems-client
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Satvision Smart Systems VMS client from the official site"
URL="https://satvision-cctv.ru/base/instructions/608/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# Ubuntu/Astra client deb on Yandex Disk
PKGURL="https://disk.yandex.ru/d/U_iXayNVdgVKXQ"

install_pkgurl
