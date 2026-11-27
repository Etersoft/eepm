#!/bin/sh

PKGNAME=rutokenplugin
SUPPORTEDARCHES="x86_64 aarch64"
VERSION="$2"
DESCRIPTION="Rutoken Plugin (digital signature in browsers) from the official site"
URL="https://www.rutoken.ru/products/all/rutoken-plugin/"

. $(dirname $0)/common.sh

base_url="https://download.rutoken.ru/Rutoken_Plugin"

if [ "$VERSION" = "*" ] ; then
    # Version: v.4.13.0.0
    VERSION="$(fetch_url "$base_url/Current/version.txt" | sed -n 's|^Version: *v\.*\([0-9.]*\).*|\1|p' | sed -e 's|\.0$||')"
    [ -n "$VERSION" ] || fatal "Can't get version."
fi

# directories are named with four version components (4.13.0.0), packages with three (4.13.0)
url="$base_url/$VERSION.0/Linux"

arch="$(epm print info -a)"
case "$(epm print info -p)" in
    rpm)
        if [ "$(epm print info -s)" = "alt" ] ; then
            # https://download.rutoken.ru/Rutoken_Plugin/4.13.0.0/Linux/libnpRutokenPlugin-4.13.0-alt1.x86_64.rpm
            PKGURL="$url/libnpRutokenPlugin-$VERSION-alt1.$arch.rpm"
        else
            # https://download.rutoken.ru/Rutoken_Plugin/4.13.0.0/Linux/libnpRutokenPlugin-4.13.0-1.x86_64.rpm
            PKGURL="$url/libnpRutokenPlugin-$VERSION-1.$arch.rpm"
        fi
        ;;
    *)
        # https://download.rutoken.ru/Rutoken_Plugin/4.13.0.0/Linux/libnpRutokenPlugin_4.13.0-1_amd64.deb
        PKGURL="$url/libnpRutokenPlugin_$VERSION-1_$(epm print info --debian-arch).deb"
        ;;
esac

install_pkgurl || exit

echo
echo 'Note: install the Rutoken Plugin adapter extension in your browser:'
echo '  Chromium-based browsers (Google Chrome, Chromium, Yandex Browser, Chromium-Gost): https://chromewebstore.google.com/detail/ohedcglhbbfdgaogjhcclacoccbagkjg'
echo '  Firefox: search for the Rutoken Plugin adapter on https://addons.mozilla.org'
echo 'The pcscd service must be running to work with Rutoken: serv pcscd on'
