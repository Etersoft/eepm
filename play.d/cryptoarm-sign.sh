#!/bin/sh

PKGNAME=cryptoarm-sign
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="CryptoARM Sign (digital signature and file encryption) from the official site"
URL="https://cryptoarm.ru/"
TIPS="CryptoARM Sign requires CryptoPro CSP (it is not installed automatically). Install it with 'ecryptomgr install cprocsp' (https://github.com/Etersoft/ecryptomgr)."

. $(dirname $0)/common.sh

BASEURL="https://ftp.digt.ru/web/PublicReleases/CryptoARM_Sign"

if [ "$VERSION" = "*" ] ; then
    # skip -beta.N directories
    VERSION="$(fetch_url "$BASEURL/" | grep -o 'href="v[0-9][0-9.]*/"' | sed -e 's|^href="v||' -e 's|/"$||' | sort -V | tail -n1)"
    [ -n "$VERSION" ] || fatal "Can't get the latest version from $BASEURL"
fi

PKGURL="$BASEURL/v$VERSION/cryptoarm-sign-$VERSION.x86_64.rpm"

install_pkgurl || exit

echo
info 'CryptoARM Sign needs CryptoPro CSP to work. Install it with ecryptomgr install cprocsp'
