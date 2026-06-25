#!/bin/sh

PKGNAME=anydesk
SUPPORTEDARCHES="x86_64"
VERSION="$2"
RELEASE="$3"
DESCRIPTION="AnyDesk from the official site"
URL="https://anydesk.com/en/downloads/linux"

. $(dirname $0)/common.sh

# current links:

# the repo keeps only the current version, older ones are not available
warn_version_is_not_supported

[ "$VERSION" = "*" ] || VERSION="${VERSION}-${RELEASE}"

# anydesk.com/download.anydesk.com are behind Cloudflare (403/429 for wget),
# use the plain nginx RPM repo instead
# https://rpm.anydesk.com/centos/7/x86_64/Packages/anydesk_8.0.3-1_x86_64.rpm
REPOURL="https://rpm.anydesk.com/centos/7/x86_64/Packages"
PKGMASK="$(epm print constructname $PKGNAME "$VERSION" '' '' '_')"

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget -A --list --latest "$REPOURL/" "$PKGMASK")"
else
    PKGURL="$REPOURL/$PKGMASK"
fi

install_pkgurl || exit

echo
echo "Note: run
# serv anydesk on
to enable needed anydesk system service
"
