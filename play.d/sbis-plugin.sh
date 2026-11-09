#!/bin/sh

PKGNAME="sbis3plugin sbis-libstdc++12 sbis3plugin-additions saby-minimal-core"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION=''
URL="https://saby.ru/help/plugin/sbis3plugin"

. $(dirname $0)/common.sh

info "The SBIS plugin is no longer distributed separately upstream. Its browser integration is now provided as part of Saby Desktop."
info "Saby will be installed instead. To remove it, run 'epmp --remove saby'."
epm play saby
