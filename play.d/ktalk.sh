#!/bin/sh

PKGNAME=ktalk
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Контур.Толк (ktalk) from the official site"

. $(dirname $0)/common.sh

warn_version_is_not_supported

case "$(epm print info -d)" in
    ALTLinux)
        epm install --skip-installed at-spi2-atk glib2 libalsa libatk libat-spi2-core libcairo libcups libdbus libdbus-glib libdbusmenu libdbusmenu-gtk2 libdrm libexpat libgbm libgdk-pixbuf libgio libgtk+2 libgtk+3 libindicator libpango libX11 libxcb libXcomposite libXdamage libXext libXfixes libxkbcommon libXrandr
        ;;
esac


URL="https://app.ktalk.ru/system/dist/download/linux"

# curl can't get filename: https://github.com/curl/curl/issues/8461
epm assure wget || fatal

cd_to_temp_dir

#epm tool eget --no-check-certificate "$URL" || fatal
epm tool eget "$URL" || fatal

# ktalk2.5 -> ktalk-2.5
newname="$(echo *.AppImage | sed -e "s|^ktalk2|$PKGNAME-2|" )"
mv -v *.AppImage $newname

epm install $newname
