#!/bin/sh

BASEPKGNAME=Telegram
PRODUCTALT="'' beta"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Telegram client from the official site"
URL="https://github.com/telegramdesktop/tdesktop"
TIPS="Run 'epm play telegram=beta' to install beta version of the Telegram client. Run 'epm play telegram version' to install the version of the Telegram client."

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    [ "$PKGNAME" = "$BASEPKGNAME" ] || VERSION="*beta"
    if ! is_glibc_enough 2.32 ; then
        VERSION="4.9.5"
    fi
    if ! is_glibc_enough 2.28 ; then
        fatal "glibc is too old, upgrade your system."
    fi
else
    VERSION="$VERSION*"
fi


PKGURL=$(eget --list --latest https://github.com/telegramdesktop/tdesktop/releases "tsetup.$VERSION.tar.xz") #"

# override PKGNAME for beta version
echo "$PKGURL" | grep -q "beta.tar.xz" && override_pkgname "$BASEPKGNAME-beta"

install_pack_pkgurl
