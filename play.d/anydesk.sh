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

# we have workaround for their postinstall script, so always repack rpm package
repack=''
[ "$(epm print info -s)" = "alt" ] && repack='--repack'

# rpm packages have a release in their names
[ "$(epm print info -p)" = "rpm" ] && [ "$VERSION" != "*" ] && VERSION="$VERSION-1"


# current links:
# https://download.anydesk.com/rpm/anydesk_6.0.1-1_x86_64.rpm
# https://download.anydesk.com/os-specific/rhel8/anydesk-6.0.1-1.el8.x86_64.rpm
# https://download.anydesk.com/deb/anydesk_6.0.1-1_amd64.deb

# general msk
#PKGMASK="$(epm print info -p)/$(epm print constructname $PKGNAME "*" $arch '' '_')"
# TODO: hack with version, there are too many files
PKGMASK="$(epm print constructname $PKGNAME "$VERSION" $arch '' '_')"

# we miss obsoleted libpangox on ALT, so use RHEL8 build
# lib.req: WARNING: /usr/bin/anydesk: library libpangox-1.0.so.0 not found
#[ "$(epm print info -s)" = "alt" ] && PKGMASK="os-specific/rhel8/$(epm print constructname $PKGNAME "*" $arch)"

PKGURL="$(eget --list --latest https://download.anydesk.com/linux/ ./$PKGMASK)" || fatal "Can't get package URL"

epm $repack install "$PKGURL" || exit

echo
echo "Note: run
# serv anydesk on
to enable needed anydesk system service
"
