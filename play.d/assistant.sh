#!/bin/sh

PKGNAME=assistant
SUPPORTEDARCHES="x86_64 aarch64"
DESCRIPTION="Assistant (Ассистент) from the official site"

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
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
trap "rm -f $tmpfile" EXIT
epm tool eget -q -O- "$URL" | grep -A200 "Ассистент для LINUX" >$tmpfile

url_by_text()
{
    local text="$1"
    local pkg="$(cat $tmpfile | grep -B1 "$text" | head -n1 | grep "/Download/" | sed -e 's|.*href="||' -e 's|".*||')"
    [ -n "$pkg" ] || fatal "Can't get Download href for $text"
    #echo "https://мойассистент.рф$pkg"
    echo "https://xn--80akicokc0aablc.xn--p1ai$pkg"
}

case $arch-$pkg in
    x86_64-rpm)
        URL="$(url_by_text "Скачать RPM пакет")"
        ;;
    x86_64-deb)
        URL="$(url_by_text "Скачать DEB пакет")"
        ;;
    aarch64-rpm)
        URL="$(url_by_text "Скачать RPM пакет для ARM устройств")"
        ;;
    aarch64-deb)
        URL="$(url_by_text "Скачать DEB пакет для ARM устройств")"
        ;;
    *)
        fatal "$($DISTRVENDOR -e) is not supported (arch $arch, package type is $pkg)"
        ;;
esac

# after repack on ALT:
#  assistant: Требует: /lib/init/vars.sh но пакет не может быть установлен
#             Требует: libyuv.so()(64bit) но пакет не может быть установлен

[ "$($DISTRVENDOR -s)" = "alt" ] && epmi --skip-installed fontconfig-disable-type1-font-for-assistant

LANG=ru_RU.UTF8 epm install "$URL" || exit

# TODO:
# after install:
#/usr/share/assistantd/daemon.sh --install
#/opt/assistant/scripts/fonts.sh --install
