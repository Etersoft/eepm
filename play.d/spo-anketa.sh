#!/bin/sh

PKGNAME=spo-anketa
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="СПО «Анкета ГС (МС)» для заполнения анкеты госслужащего"
URL="https://gossluzhba.gov.ru/spo/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# Native packages from gossluzhba.gov.ru
# Version 1.3.2 from 06.2026
pkgtype="$(epm print info -p)"

case $pkgtype in
    deb)
        # SPO_AstraLinux_1_3_2.deb
        PKGURL="https://files.gossluzhba.gov.ru/49309a89-3c66-408c-805a-2d42b28e89c9/download/4cd9c732-ee4e-4dc6-9f44-83b2cf4e3a72"
        ;;
    *)
        # SPO_RedOS_AltLinux_1_3_2.rpm
        PKGURL="https://files.gossluzhba.gov.ru/49309a89-3c66-408c-805a-2d42b28e89c9/download/92b8266d-11c2-4972-8217-d2987d1b1377"
        ;;
esac

install_pkgurl
