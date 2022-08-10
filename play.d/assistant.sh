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

# some locale depend troubles (ALT with bash 4 needs LANG=ru_RU.UTF-8, Ubuntu with bash 5 needs LANG=C.UTF-8)
#URL="https://мойассистент.рф/скачать"
URL="https://xn--80akicokc0aablc.xn--p1ai/%D1%81%D0%BA%D0%B0%D1%87%D0%B0%D1%82%D1%8C"
if ! LANG=ru_RU.UTF8 check_url_is_accessible "$URL" ; then
    epm tool eget -O- "$URL"
    fatal "Please, check why $URL is not accessible"
fi

# parse vendor site
tmpfile=$(mktemp)
epm tool eget -q -O- "$URL" | grep -A50 "Ассистент для LINUX" >$tmpfile

url_by_order()
{
    local order="$1"
    local pkg="$(cat $tmpfile | grep "/Download/" | $order -n1 | sed -e 's|.*href="||' -e 's|".*||')"
    [ -n "$pkg" ] || fatal "Can't get Download href"
    #echo "https://мойассистент.рф$pkg"
    echo "https://xn--80akicokc0aablc.xn--p1ai$pkg"
}

case $arch-$pkg in
    x86_64-rpm)
        URL="$(url_by_order head)"
        ;;
    x86_64-deb)
        URL="$(url_by_order tail)"
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
