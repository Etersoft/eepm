#!/bin/sh

PKGNAME=assistant
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Assistant (Ассистент) from the official site"

# Assistant reclaim their rpm package supports ALT
repack="--scripts"

if [ "$1" = "--remove" ] ; then
    epm remove $repack $PKGNAME
    exit
fi

. $(dirname $0)/common.sh


arch="$($DISTRVENDOR -a)"

pkg="$($DISTRVENDOR -p)"

case $arch-$pkg in
    x86_64-rpm)
        URL="https://мойассистент.рф/%D1%81%D0%BA%D0%B0%D1%87%D0%B0%D1%82%D1%8C/Download/542"
        OPKG=assistant-4.8-0.x86_64.rpm
        ;;
    x86_64-deb)
        URL="https://мойассистент.рф/%D1%81%D0%BA%D0%B0%D1%87%D0%B0%D1%82%D1%8C/Download/545"
        OPKG=assistant_4.8-0_amd64.deb
        ;;
    aarch64-rpm)
        URL="https://мойассистент.рф/%D1%81%D0%BA%D0%B0%D1%87%D0%B0%D1%82%D1%8C/Download/551"
        OPKG=assistant-4.8-0.x86_64.rpm
        ;;
    aarch64-deb)
        URL="https://мойассистент.рф/%D1%81%D0%BA%D0%B0%D1%87%D0%B0%D1%82%D1%8C/Download/552"
        OPKG=assistant_4.8-0_amd64.deb
        ;;
    *)
        fatal "$($DISTRVENDOR -e) is not supported (arch $arch, package type is $pkg)"
        ;;
esac

# after repack on ALT:
#  assistant: Требует: /lib/init/vars.sh но пакет не может быть установлен
#             Требует: libyuv.so()(64bit) но пакет не может быть установлен

#repack=''
#[ "$($DISTRVENDOR -p)" = "deb" ] || repack='--repack'

[ "$($DISTRVENDOR -d)" = "ALTLinux" ] && epmi --skip-installed fontconfig-disable-type1-font-for-assistant

LANG=ru_RU.UTF8 epm $repack install "$URL" || exit

[ "$repack" = "--scripts" ] && echo "Warning! Privileged scripts from the vendor were running."

# TODO:
# after install:
#/usr/share/assistantd/daemon.sh --install
#/opt/assistant/scripts/fonts.sh --install
