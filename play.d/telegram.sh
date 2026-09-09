#!/bin/sh

BASEPKGNAME=Telegram
PRODUCTALT="'' beta"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="Telegram client from the official site"
URL="https://github.com/telegramdesktop/tdesktop"
TIPS="Run 'epm play telegram=beta' to install beta version of the Telegram client."

. $(dirname $0)/common.sh

# override only checked version and latest version
if [ -n "$CHECKED_VERSION" ] || [ "$VERSION" = "*" ] ; then
    if ! is_glibc_enough 2.28 ; then
        VERSION="4.5.1"
        info "glibc version below 2.28, we'll stick with the old version $VERSION"
    elif ! is_glibc_enough 2.32 ; then
        VERSION="4.9.5"
        info "glibc version below 2.32, we'll stick with the old version $VERSION"
    fi
fi

if [ "$VERSION" = "*" ] ; then
    if [ "$PKGNAME" = "$BASEPKGNAME-beta" ] ; then
        prerelease="prerelease"
        mask="td-setup-linux-x64-*-beta.tar.xz"
    else
        mask="td-setup-linux-x64-*.tar.xz"
    fi
    # can't use get_github_tag (not every tag has binary release)
    PKGURL=$(get_github_url "https://github.com/telegramdesktop/tdesktop/" "$mask" $prerelease)

else
    # Beta releases use tag v1.2.3, without the beta suffix.
    TAGVER="$(echo "$VERSION" | sed -e 's/\.beta$//' -e 's/-beta$//')"
    PKGBASEURL="https://github.com/telegramdesktop/tdesktop/releases/download/v$TAGVER"

    case "$PKGNAME" in
        "$BASEPKGNAME-beta")
            rename_version=7.2.6
            old_suffix=.beta
            new_suffix=-beta
            ;;
        *)
            rename_version=7.2.7
            old_suffix=
            new_suffix=
            ;;
    esac

    if is_version_older "$TAGVER" "$rename_version" ; then
        filename="tsetup.$TAGVER$old_suffix.tar.xz"
    else
        filename="td-setup-linux-x64-$TAGVER$new_suffix.tar.xz"
    fi
    PKGURL="$PKGBASEURL/$filename"
fi

# override PKGNAME for beta version
echo "$PKGURL" | grep -q "beta.tar.xz" && override_pkgname "$BASEPKGNAME-beta"

install_pack_pkgurl
