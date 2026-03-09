#!/bin/sh

PKGNAME=satvision-smart-systems
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Satvision Smart Systems VMS server from the official site"
URL="https://satvision-cctv.ru/base/instructions/608/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# Ubuntu/Astra server deb on Yandex Disk
PKGURL="https://disk.yandex.ru/d/0rgh7pSMVMefeg"

install_pkgurl
