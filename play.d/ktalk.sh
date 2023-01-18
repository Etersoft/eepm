#!/bin/sh

PKGNAME=ktalk
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Контур.Толк (ktalk) from the official site"

. $(dirname $0)/common.sh


case "$(epm print info -d)" in
    ALTLinux|ALTServer)
        epm install --skip-installed at-spi2-atk glib2 libalsa libatk libat-spi2-core libcairo libcups libdbus libdbus-glib libdbusmenu libdbusmenu-gtk2 libdrm libexpat libgbm libgdk-pixbuf libgio libgtk+2 libgtk+3 libindicator libpango libX11 libxcb libXcomposite libXdamage libXext libXfixes libxkbcommon libXrandr
        ;;
esac


URL="https://app.ktalk.ru/system/dist/download/linux"

# curl can't get filename: https://github.com/curl/curl/issues/8461
epm assure wget || fatal

# hack due ОШИБКА: невозможно проверить сертификат app.ktalk.ru, выпущенный «CN=RapidSSL TLS DV RSA Mixed SHA256 2020 CA-1,O=DigiCert Inc,C=US»
PKGDIR="$(mktemp -d)"
trap "rm -fr $PKGDIR" EXIT
cd $PKGDIR || fatal
epm tool eget --no-check-certificate "$URL" || fatal

epm install *.AppImage
