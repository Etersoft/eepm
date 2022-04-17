#!/bin/sh

PKGNAME=ktalk
DESCRIPTION="Контур.Толк (ktalk) from the official site"

. $(dirname $0)/common.sh


[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

URL="https://app.ktalk.ru/system/dist/download/linux"

# hack due ОШИБКА: невозможно проверить сертификат app.ktalk.ru, выпущенный «CN=RapidSSL TLS DV RSA Mixed SHA256 2020 CA-1,O=DigiCert Inc,C=US»
PKGDIR="$(mktemp -d)"
cd $PKGDIR || fatal
$EGET --no-check-certificate "$URL"

epm install *.AppImage
RES=$?
rm -rf $PKGDIR
exit $RES
