#!/bin/sh

PKGNAME=whatsapp-for-linux
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION='An unofficial WhatsApp desktop application (from the repository if the package is there, or from the official site)'

. $(dirname $0)/common.sh

if epm install $PKGNAME ; then
    return
fi

[ "$(epm print info -s)" = "alt" ] && fatal "ALT is not supports $PKGNAME AppImage for now."

#case "$(epm print info -d)" in
#    ALTLinux|ALTServer)
#        epm install --skip-installed at-spi2-atk glib2 libalsa libatk libat-spi2-core libcairo libcups libdbus libdbus-glib libdbusmenu libdbusmenu-gtk2 libdrm libexpat libgbm libgdk-pixbuf libgio libgtk+2 libgtk+3 libindicator libpango libX11 libxcb libXcomposite libXdamage libXext libXfixes libxkbcommon libXrandr
#        ;;
#esac
arch=x86_64
# sh: symbol lookup error: /tmp/.private/lav/.mount_whatsaxhRMDh/opt/libc/lib/x86_64-linux-gnu/libc.so.6: undefined symbol: __libc_enable_secure, version GLIBC_PRIVATE
URL=$(epm tool eget --list --latest https://github.com/eneshecan/whatsapp-for-linux/releases "$PKGNAME-$VERSION-$arch.AppImage") || fatal "Can't get package URL"
epm install $URL

