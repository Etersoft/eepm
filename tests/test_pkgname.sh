#!/bin/sh

__set_version_pkgname()
{
    local alpkg="$1"
    VERSION="$(echo "$alpkg" | grep -o -P "[-_.]([0-9])([0-9])*(\.[0-9])*" | head -n1 | sed -e 's|^[-_.]||')" #"
    [ -n "$VERSION" ] && PKGNAME="$(echo "$alpkg" | sed -e "s|[-_.]$VERSION.*||")"
}

NAME="Telegram.4.0.4.beta.tar"
__set_version_pkgname $NAME
echo "$NAME: $PKGNAME -- $VERSION"

# $ fakeroot alien -d -k Telegram.4.0.4.beta.tar
# telegram.4.0.4.beta_1-1_all.deb
