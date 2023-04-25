#!/bin/sh

PKGNAME=whatsapp-for-linux
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='' #"An unofficial WhatsApp desktop application for Linux"

. $(dirname $0)/common.sh


#case "$(epm print info -d)" in
#    ALTLinux|ALTServer)
#        epm install --skip-installed at-spi2-atk glib2 libalsa libatk libat-spi2-core libcairo libcups libdbus libdbus-glib libdbusmenu libdbusmenu-gtk2 libdrm libexpat libgbm libgdk-pixbuf libgio libgtk+2 libgtk+3 libindicator libpango libX11 libxcb libXcomposite libXdamage libXext libXfixes libxkbcommon libXrandr
#        ;;
#esac
arch=x86_64
URL=$(epm tool eget --list --latest https://github.com/eneshecan/whatsapp-for-linux/releases "$PKGNAME-$VERSION-$arch.AppImage") || fatal "Can't get package URL"
epm install $URL

