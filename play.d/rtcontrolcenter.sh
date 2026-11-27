#!/bin/sh

PKGNAME=rtcontrolcenter
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Rutoken Control Center (Rutoken devices management) from the official site"
URL="https://www.rutoken.ru/support/download/rutoken-control-center/"

. $(dirname $0)/common.sh

base_url="https://download.rutoken.ru/Rutoken/Control_Center"

if [ "$VERSION" = "*" ] ; then
    # Current/ is not updated, so get the latest versioned directory
    VERSION="$(fetch_url "$base_url/" | grep -o 'href="[0-9][0-9.]*/"' | sed -e 's|href="\(.*\)/"|\1|' | sort -V | tail -n1)"
    [ -n "$VERSION" ] || fatal "Can't get version."
fi

case "$(epm print info -a)" in
    x86_64)
        dirarch=x86_64
        ;;
    aarch64)
        dirarch=arm64
        ;;
esac

url="$base_url/$VERSION/Linux/$dirarch"

arch="$(epm print info -a)"
case "$(epm print info -p)" in
    rpm)
        if [ "$(epm print info -s)" = "alt" ] ; then
            # https://download.rutoken.ru/Rutoken/Control_Center/1.2.0/Linux/x86_64/rtcontrolcenter-1.2.0-alt1.x86_64.rpm
            PKGURL="$url/rtcontrolcenter-$VERSION-alt1.$arch.rpm"
        else
            # https://download.rutoken.ru/Rutoken/Control_Center/1.2.0/Linux/x86_64/rtcontrolcenter-1.2.0-1.x86_64.rpm
            PKGURL="$url/rtcontrolcenter-$VERSION-1.$arch.rpm"
        fi
        ;;
    *)
        # https://download.rutoken.ru/Rutoken/Control_Center/1.2.0/Linux/x86_64/rtcontrolcenter_1.2.0-1_amd64.deb
        PKGURL="$url/rtcontrolcenter_$VERSION-1_$(epm print info --debian-arch).deb"
        ;;
esac

install_pkgurl || exit

echo
echo 'The pcscd service must be running to work with Rutoken: serv pcscd on'
