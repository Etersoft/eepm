#!/bin/sh

PKGNAME=virtualhere
SUPPORTEDARCHES="x86_64 armhf mips mipsel aarch64 x86"
VERSION="$2"
DESCRIPTION='Generic VirtualHere USB Server from the official site'
URL="https://www.virtualhere.com/"

. $(dirname $0)/common.sh

warn_version_is_not_supported

arch="$(epm print info -a)"
case "$arch" in
    x86_64)
        file="vhusbdx86_64"
        ;;
    x86)
        file="vhusbdi386"
        ;;
    armhf)
        file="vhusbdarm"
        ;;
    mips)
        file="vhusbdmips"
        ;;
    mipsel)
        file="vhusbdmipsel"
        ;;
    aarch64)
        file="vhusbdarm64"
        ;;
    *)
        fatal "$arch arch is not supported"
        ;;
esac

# https://www.virtualhere.com/sites/default/files/usbserver/vhusbdx86_64
PKGURL="https://www.virtualhere.com/sites/default/files/usbserver/$file"

# FIXME
VERSION="*"
if [ "$VERSION" = "*" ] ; then
    VERSION="$(eget -O- https://virtualhere.com/usb_server_software | grep "<strong>Version" | sed -e 's|.*<strong>Version ||' -e 's|</strong>.*||')"
    [ -n "$VERSION" ] || fatal "Can't get version for $PKGNAME"
fi

epm pack --install $PKGNAME "$PKGURL" $VERSION || exit

echo
echo "Note: run
# serv $PKGNAME on
to enable and start $PKGNAME system service
"
