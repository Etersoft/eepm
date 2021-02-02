#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=assistant
# Assistant reclaim their rpm package supports ALT
repack="--scripts"


if [ "$1" = "--remove" ] ; then
    epm remove $repack $PKGNAME
    exit
fi

[ "$1" != "--run" ] && echo "Install Assistant (Ассистент) from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

pkg="$($DISTRVENDOR -p)"

# TODO: why wget/curl are not supported download-to?
case $pkg in
    rpm)
        URL="https://xn--80akicokc0aablc.xn--p1ai/%D1%81%D0%BA%D0%B0%D1%87%D0%B0%D1%82%D1%8C/Download/338"
        OPKG=assistant-4.0-699.x86_64.rpm
        ;;
    deb)
        URL="https://xn--80akicokc0aablc.xn--p1ai/%D1%81%D0%BA%D0%B0%D1%87%D0%B0%D1%82%D1%8C/Download/337"
        OPKG=assistant_4.0-700_amd64.deb
        ;;
    *)
        fatal "$($DISTRVENDOR -e) is not supported (package type is $pkg)"
        ;;
esac

# after repack on ALT:
#  assistant: Требует: /lib/init/vars.sh но пакет не может быть установлен
#             Требует: libyuv.so()(64bit) но пакет не может быть установлен

#repack=''
#[ "$($DISTRVENDOR -p)" = "deb" ] || repack='--repack'


OPKG=/tmp/$OPKG
$EGET -O $OPKG $URL
epm $repack install "$OPKG" || exit
rm -fv $OPKG

[ "$repack" = "--scripts" ] && echo "Warning! Privileged scripts from the vendor were running."

# after install:
#/usr/share/assistantd/daemon.sh --install
#/opt/assistant/scripts/fonts.sh --install
