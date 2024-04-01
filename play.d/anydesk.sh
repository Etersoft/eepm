#!/bin/sh

PKGNAME=anydesk
SUPPORTEDARCHES="x86_64 x86"
VERSION="$2"
DESCRIPTION="AnyDesk from the official site"

. $(dirname $0)/common.sh

arch=$(epm print info --distro-arch)
case $arch in
    x86_64|amd64)
        arch=$arch ;;
    i686|i386)
        arch=$arch ;;
    i586)
        arch=i686 ;;
    *)
        fatal "Unsupported arch $arch for $(epm print info -d)"
esac

# rpm packages have a release in their names
[ "$(epm print info -p)" = "rpm" ] && [ "$VERSION" != "*" ] && VERSION="$VERSION-1"


# current links:
# https://download.anydesk.com/rpm/anydesk_6.0.1-1_x86_64.rpm
# https://download.anydesk.com/os-specific/rhel8/anydesk-6.0.1-1.el8.x86_64.rpm
# https://download.anydesk.com/deb/anydesk_6.0.1-1_amd64.deb

PKGMASK="$(epm print constructname $PKGNAME "$VERSION" $arch '' '_')"

# we miss obsoleted libpangox on ALT, so use RHEL8 build
# lib.req: WARNING: /usr/bin/anydesk: library libpangox-1.0.so.0 not found
#[ "$(epm print info -s)" = "alt" ] && PKGMASK="os-specific/rhel8/$(epm print constructname $PKGNAME "*" $arch)"

if [ "$VERSION" = "*" ] ; then
    PKGURL="$(eget --list --latest https://download.anydesk.com/linux/ "./$PKGMASK")"
else
    # https://download.anydesk.com/linux/anydesk_6.3.0-1_amd64.deb
    # https://download.anydesk.com/linux/anydesk_6.3.0-1_x86_64.rpm
    PKGURL="https://download.anydesk.com/linux/$PKGMASK"
fi

install_pkgurl

echo
echo "Note: run
# serv anydesk on
to enable needed anydesk system service
"
