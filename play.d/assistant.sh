#!/bin/sh

PKGNAME=assistant
SKIPREPACK=1
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Assistant (Ассистент) from the official site"
URL="https://мойассистент.рф"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch="$(epm print info -a)"
pkg="$(epm print info -p)"

# Vendor site is SPA, download links are only available via API
# Platform 2 = Linux; item IDs: 1376=RPM, 1375=DEB, 1382=RPM ARM, 1383=DEB ARM
DLBASE="https://lk2.xn--80akicokc0aablc.xn--p1ai/WebApi/Platforms/Download"

case $arch-$pkg in
    x86_64-rpm)
        PKGURL="$DLBASE/1376"
        ;;
    x86_64-deb)
        PKGURL="$DLBASE/1375"
        ;;
    aarch64-rpm)
        PKGURL="$DLBASE/1382"
        ;;
    aarch64-deb)
        PKGURL="$DLBASE/1383"
        ;;
    *)
        fatal "$(epm print info -e) is not supported (arch $arch, package type is $pkg)"
        ;;
esac

# after repack on ALT:
#  assistant: Требует: /lib/init/vars.sh но пакет не может быть установлен
#             Требует: libyuv.so()(64bit) но пакет не может быть установлен

[ "$(epm print info -s)" = "alt" ] && epmi --skip-installed fontconfig-disable-type1-font-for-assistant

LANG=ru_RU.UTF8 install_pkgurl || exit

echo "Note:
Vendor suggest run /opt/assistant/scripts/setup.sh --install after install.
Vendor suggest run /opt/assistant/scripts/setup.sh --uninstall before removing the package.
Warning! This script will setup daemon. It is dangerous. Use this script and this package at your own risk.
"
