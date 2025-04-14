#!/bin/sh

PKGNAME=rememberthemilk
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='The smart to-do app for busy people'
URL="https://www.rememberthemilk.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# https://www.rememberthemilk.com/services/linux/
PKGURL="https://www.rememberthemilk.com/download/linux/debian/pool/main/r/rememberthemilk/rememberthemilk_1.3.11_amd64.deb"

install_pkgurl
