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

# parse vendor site
tmpfile=$(mktemp)
epm tool eget -q -O- "https://мойассистент.рф/скачать" | grep -A50 "Ассистент для LINUX" >$tmpfile

url_by_order()
{
    local order="$1"
    echo "https://мойассистент.рф$(cat $tmpfile | grep "/Download/" | $order -n1 | sed -e 's|.*href="||' -e 's|".*||')"
}

version=$(cat $tmpfile | grep -A1 "Версия:" | tail -n1 | sed -e 's|.*<span class="v">||' -e 's| .*||')
[ -n "$version" ] || fatal "Can't get package version"

case $arch-$pkg in
    x86_64-rpm)
        URL="$(url_by_order head)"
        OPKG=assistant-$version-0.x86_64.rpm
        ;;
    x86_64-deb)
        URL="$(url_by_order tail)"
        OPKG=assistant_$version-0_amd64.deb
        ;;
    *)
        fatal "$($DISTRVENDOR -e) is not supported (arch $arch, package type is $pkg)"
        ;;
esac

rm $tmpfile

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
