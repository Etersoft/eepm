#!/bin/sh

PKGNAME=gosuslugi-plugin
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="официальный плагин для входа на Госуслуги по сертификату электронной подписи и подписания документов усиленной квалифицированной электронной подписью (УКЭП)"
URL="https://www.gosuslugi.ru/landing/gosplugin"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL="https://gu-st.ru/content/Gosplugin/Gosplugin_Linux-Debian_Installer.deb.sh"

install_pack_pkgurl || fatal 

echo
echo "Не забудьте также установить расширение для браузера:"
echo "  • Chrome / Chromium / Edge / Яндекс —  https://chromewebstore.google.com/detail/%D0%B3%D0%BE%D1%81%D0%BF%D0%BB%D0%B0%D0%B3%D0%B8%D0%BD/jabjbhgjaidecageckilhonbggakppme/"
echo "  • Firefox — https://addons.mozilla.org/ru/firefox/addon/%D0%B3%D0%BE%D1%81%D0%BF%D0%BB%D0%B0%D0%B3%D0%B8%D0%BD/"

