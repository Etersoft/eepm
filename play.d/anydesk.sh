#!/bin/sh

PKGNAME=anydesk
DESCRIPTION="AnyDesk from the official site"

. $(dirname $0)/common.sh


arch=$($DISTRVENDOR --distro-arch)
case $arch in
    x86_64|amd64)
        arch=$arch ;;
    i686|i386)
        arch=$arch ;;
    i586)
        arch=i686 ;;
    *)
        fatal "Unsupported arch $arch for $($DISTRVENDOR -d)"
esac

# we have workaround for their postinstall script, so always repack rpm package
repack=''
[ "$($DISTRVENDOR -p)" = "deb" ] || repack='--repack'

# current links:
# https://download.anydesk.com/rpm/anydesk_6.0.1-1_x86_64.rpm
# https://download.anydesk.com/os-specific/rhel8/anydesk-6.0.1-1.el8.x86_64.rpm
# https://download.anydesk.com/deb/anydesk_6.0.1-1_amd64.deb

# general msk
#PKGMASK="$($DISTRVENDOR -p)/$(epm print constructname $PKGNAME "*" $arch '' '_')"
PKGMASK="$(epm print constructname $PKGNAME "6.1*" $arch '' '_')"

# we miss obsoleted libpangox on ALT, so use RHEL8 build
# lib.req: WARNING: /usr/bin/anydesk: library libpangox-1.0.so.0 not found
#[ "$($DISTRVENDOR -s)" = "alt" ] && PKGMASK="os-specific/rhel8/$(epm print constructname $PKGNAME "*" $arch)"

PKG="$($EGET --list --latest https://download.anydesk.com/linux $PKGMASK)" || fatal "Can't get package URL"

epm $repack install "$PKG" || exit

echo
echo "Note: run
# serv anydesk on
to enable needed anydesk system service
"
