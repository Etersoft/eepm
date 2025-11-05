#!/bin/sh

BASEPKGNAME=Telegram
PRODUCTALT="'' beta"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Telegram client from the official site"
URL="https://github.com/telegramdesktop/tdesktop"
TIPS="Run 'epm play telegram=beta' to install beta version of the Telegram client."

. $(dirname $0)/common.sh

# override checked version or determine latest version
if [ -n "$CHECKED_VERSION" ] || [ "$VERSION" = "*" ] ; then
    if ! is_glibc_enough 2.32 ; then
        VERSION="4.9.5"
    fi

    if ! is_glibc_enough 2.28 ; then
        VERSION="4.5.1"
    fi
fi

if [ "$VERSION" = "*" ] ; then
    if [ "$PKGNAME" = "$BASEPKGNAME-beta" ] ; then
        prerelease="prerelease"
        VERSION="$VERSION.beta"
    fi
    # can't use get_github_tag (not every tag has binary release)
    PKGURL=$(get_github_url "https://github.com/telegramdesktop/tdesktop/" "tsetup.$VERSION.tar.xz" $prerelease)

else
    PKGBASEURL="https://github.com/telegramdesktop/tdesktop/releases/download/v$VERSION"
    [ "$PKGNAME" = "$BASEPKGNAME-beta" ] && VERSION="$VERSION.beta"
    # version can be 1.2.3.beta or 1.2.3
    PKGURL="$PKGBASEURL/tsetup.$VERSION.tar.xz"
fi

# override PKGNAME for beta version
echo "$PKGURL" | grep -q "beta.tar.xz" && override_pkgname "$BASEPKGNAME-beta"

install_pack_pkgurl
