#!/bin/sh

PKGNAME=alteroffice
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='AlterOffice from the official site'
URL="https://alteroffice.ru/"
BASEVER="3.0"

. $(dirname $0)/common.sh

warn_version_is_not_supported

case $(epm print info -s) in
    alt)
        distr="AltLinux_x64/*.rpm" ;;
    rosa|redos)
        distr="rpm_x64/*.rpm" ;;
    debian|astra)
        distr="deb_x64/*.deb" ;;
    ubuntu)
        distr="ubuntu_x64/*.deb" ;;
    *)
        fatal $1 is not supported ;;
esac

epm install "http://repo.alter-os.ru/testing/AlterOffice/v$BASEVER/linux/x64/$distr" --scripts
