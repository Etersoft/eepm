#!/bin/sh

PKGNAME=assistant
SKIPREPACK=1
SUPPORTEDARCHES="x86_64 aarch64"
DESCRIPTION="Assistant (Ассистент) from the official site"

. $(dirname $0)/common.sh


arch="$(epm print info -a)"
pkg="$(epm print info -p)"

# some locale depend troubles (ALT with bash 4 needs LANG=ru_RU.UTF-8, Ubuntu with bash 5 needs LANG=C.UTF-8)
#URL="https://мойассистент.рф/скачать"
URL="https://xn--80akicokc0aablc.xn--p1ai/%D1%81%D0%BA%D0%B0%D1%87%D0%B0%D1%82%D1%8C"

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
        fatal "$(epm print info -e) is not supported (arch $arch, package type is $pkg)"
        ;;
esac

# after repack on ALT:
#  assistant: Требует: /lib/init/vars.sh но пакет не может быть установлен
#             Требует: libyuv.so()(64bit) но пакет не может быть установлен

[ "$(epm print info -s)" = "alt" ] && epmi --skip-installed fontconfig-disable-type1-font-for-assistant

# TODO: disable scripts (see /etc/eepm/pkgallowscripts.list)
LANG=ru_RU.UTF8 epm install "$URL" || exit

echo "Note: original package runs /opt/assistant/scripts/setup.sh --install during install.."
echo "It is dangerous. Use this package at your own risk."
