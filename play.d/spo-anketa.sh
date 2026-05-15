#!/bin/sh

PKGNAME=spo-anketa
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="СПО «Анкета ГС (МС)» для заполнения анкеты госслужащего"
URL="https://gossluzhba.gov.ru/spo/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# Native packages from gossluzhba.gov.ru
# Version 1.3.1 from 29.04.2026
pkgtype="$(epm print info -p)"

case $pkgtype in
    deb)
        # SPO_AstraLinux_1_3_1.deb
        PKGURL="https://files.gossluzhba.gov.ru/49309a89-3c66-408c-805a-2d42b28e89c9/download/3b381967-ea64-4a14-ad63-1689089ea4f9"
        ;;
    *)
        # SPO_RedOS_AltLinux_1_3_1.rpm
        PKGURL="https://files.gossluzhba.gov.ru/49309a89-3c66-408c-805a-2d42b28e89c9/download/049b2d5e-b1aa-4f79-913d-f9f562b4fe8e"
        ;;
esac

install_pkgurl
