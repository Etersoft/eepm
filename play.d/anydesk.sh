#!/bin/sh

PKGNAME=anydesk
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="AnyDesk from the official site"
URL="https://download.anydesk.com/linux/"

. $(dirname $0)/common.sh

# current links:

[ "$VERSION" = "*" ] || VERSION="$VERSION-1"

# use el8 build for all systems
#PKGMASK="$(epm print constructname $PKGNAME "$VERSION.el8")"
# no more el8 build
# https://download.anydesk.com/linux/anydesk_7.0.0-1_x86_64.rpm
PKGMASK="$(epm print constructname $PKGNAME "$VERSION" '' '' '_')"

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest https://download.anydesk.com/linux/$PKGMASK)"
else
    PKGURL="https://download.anydesk.com/linux/$PKGMASK"
fi

install_pkgurl || exit

echo
echo "Note: run
# serv anydesk on
to enable needed anydesk system service
"
