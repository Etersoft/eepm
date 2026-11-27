#!/bin/sh

PKGNAME=cryptoarm-gost-mail
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="CryptoARM GOST 3 (file signing and encryption with GOST cryptography) from the official site"
URL="https://cryptoarm.ru/"
TIPS="CryptoARM GOST requires CryptoPro CSP (it is not installed automatically). Install it with 'ecryptomgr install cprocsp' (https://github.com/Etersoft/ecryptomgr)."

. $(dirname $0)/common.sh

BASEURL="https://ftp.digt.ru/web/PublicReleases/CryptoARM_GOST"

if [ "$VERSION" = "*" ] ; then
    VERSION="$(fetch_url "$BASEURL/" | grep -o 'href="v3\.[0-9.]*/"' | sed -e 's|^href="v||' -e 's|/"$||' | sort -V | tail -n1)"
    [ -n "$VERSION" ] || fatal "Can't get the latest version from $BASEURL"
fi

PKGURL="$BASEURL/v$VERSION/cryptoarm-gost-$VERSION-linux-x64.rpm"

install_pkgurl || exit

echo
info 'CryptoARM GOST needs CryptoPro CSP to work. Install it with ecryptomgr install cprocsp'
