#!/bin/sh

PKGNAME=BlitzScPlugin
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Blitz Smart Card Plugin (smart cards and tokens in browsers) from the official site"
URL="https://identityblitz.ru/products/smart-card-plugin/"

. $(dirname $0)/common.sh

# the vendor publishes only the latest build under a fixed name
warn_version_is_not_supported

case "$(epm print info -p)" in
    deb)
        PKGURL="https://identityblitz.ru/products/smart-card-plugin/demo/plugins/sc/deb/BlitzScPlugin.deb"
        ;;
    *)
        PKGURL="https://identityblitz.ru/products/smart-card-plugin/demo/plugins/sc/rpm/BlitzScPlugin.rpm"
        ;;
esac

install_pkgurl || exit

echo
echo 'Note: install the Blitz Smart Card Plugin extension in your browser:'
echo '  Chromium-based browsers: https://chromewebstore.google.com/detail/pomekhchngaooffdadfjnghfkaeipoba'
echo '  Firefox: https://identityblitz.ru/products/smart-card-plugin/files/blitz_smart_card_plugin_adapter-1.1.15-an+fx.xpi'
echo 'Token PKCS#11 libraries are used from the system: run ecryptomgr install rutoken 64 (Rutoken) or ecryptomgr install jacarta 64 (JaCarta).'
echo 'The pcscd service must be running to work with smart cards: serv pcscd on'
