#!/bin/sh

PKGNAME=anydesk
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="AnyDesk from the official site"

. $(dirname $0)/common.sh

warn_version_is_not_supported

# current links:
# https://download.anydesk.com/linux/anydesk_6.3.2-1_x86_64.rpm
# https://download.anydesk.com/linux/anydesk-6.3.2-1.el8.x86_64.rpm
# https://download.anydesk.com/linux/anydesk_6.3.2-1_amd64.deb

[ "$VERSION" = "*" ] || VERSION="$VERSION-1"

#PKGMASK="$(epm print constructname $PKGNAME "$VERSION" '' '' '_')"

#[ "$(epm print info -s)" = "alt" ] && 
# use el8 build for all systems
PKGMASK="$(epm print constructname $PKGNAME "$VERSION.el8")"

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest https://download.anydesk.com/linux/$PKGMASK)"
else
    PKGURL="https://download.anydesk.com/linux/$PKGMASK"
fi

install_pkgurl

echo
echo "Note: run
# serv anydesk on
to enable needed anydesk system service
"
