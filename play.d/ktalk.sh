#!/bin/sh

PKGNAME=ktalk2022
SUPPORTEDARCHES="x86_64"
DESCRIPTION="Контур.Толк (ktalk) from the official site"

. $(dirname $0)/common.sh

URL="https://app.ktalk.ru/system/dist/download/linux"

# curl can't get filename: https://github.com/curl/curl/issues/8461
epm assure wget || fatal

# hack due ОШИБКА: невозможно проверить сертификат app.ktalk.ru, выпущенный «CN=RapidSSL TLS DV RSA Mixed SHA256 2020 CA-1,O=DigiCert Inc,C=US»
PKGDIR="$(mktemp -d)"
cd $PKGDIR || fatal
epm tool eget --no-check-certificate "$URL" || fatal

epm install *.AppImage
RES=$?
rm -rf $PKGDIR
exit $RES
