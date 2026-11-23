#!/bin/sh

PKGNAME=FluxCast
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="FluxCast streams your Linux desktop to a Smart TV"
URL="https://github.com/IlyaP358/fluxcast"

. $(dirname $0)/common.sh

if [ "$VERSION" = "*" ] ; then
    VERSION="$(get_github_tag "$URL")" || fatal "Can't get FluxCast version"
fi

release_url="$URL/releases/download/v$VERSION"
PKGURL="$release_url/FluxCast-$VERSION-x86_64.AppImage"

if [ "$PKGFORMAT" = "deb" ] ; then
    codename="$(epm print info --repo-name)"
    case "$codename" in
        bookworm|trixie|noble|resolute)
            deb_url="$release_url/fluxcast_$VERSION.${codename}_amd64.deb"
            # Older releases only provided an AppImage.
            if eget --check-url "$deb_url" ; then
                PKGURL="$deb_url"
            fi
            ;;
    esac
fi

install_pkgurl
