#!/bin/sh

PKGNAME=bssCryptoPlugin
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="BSS Crypto Plugin for Internet-Client of AB Rossiya bank (from the official site)"
URL="https://online.abr.ru/ru/help/html/Basic/InstallCryptoPlagin.html"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# online.abr.ru uses a certificate issued by the Russian Trusted Root CA
epm install --skip-installed ca-certificates-digital.gov.ru || info 'Install Russian Trusted Root CA certificates (https://www.gosuslugi.ru/crt) if the download fails'

PKGURL="https://online.abr.ru/ru/help/download/bssCryptoPlugin.deb.run"

install_pack_pkgurl || exit

echo
echo "Log out and log in again, or run bssCryptoPlugin to start the plugin host app now."
