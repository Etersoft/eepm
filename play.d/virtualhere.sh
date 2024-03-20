#!/bin/sh

PKGNAME=virtualhere
PRODUCTDIR=/opt/$PKGNAME
BINNAME=vhusbd
SUPPORTEDARCHES="x86_64 armhf mips mipsel aarch64 x86"
VERSION="$2"
DESCRIPTION='Generic VirtualHere USB Server from the official site'

. $(dirname $0)/common.sh

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

pkgtype="$(epm print info -p)"

tdir=$(mktemp -d)
trap "rm -fr $tdir" EXIT
mkdir -p $tdir/opt/$PKGNAME/
cd $tdir || fatal

# https://github.com/virtualhere/script/blob/main/install_server
epm tool eget -O opt/$PKGNAME/$BINNAME https://www.virtualhere.com/sites/default/files/usbserver/$file || fatal
chmod 0755 opt/$PKGNAME/$BINNAME

pack_tar() {
    local tarname="$1"
    local file="$2"
    local destfile="$3"
    [ -n "$destfile" ] || destfile="$PRODUCTDIR/$(basename $file)"
    local dest=$(dirname $destfile)
    mkdir -p .$dest
    [ -s .$dest/$(basename $file) ] || cp -v $file .$dest/
    a='' tar cf $tarname .$(dirname $dest)
}

# FIXME
VERSION="*"
if [ "$VERSION" = "*" ] ; then
    VERSION="$(epm tool eget -O- https://virtualhere.com/usb_server_software | grep "<strong>Version" | sed -e 's|.*<strong>Version ||' -e 's|</strong>.*||')"
    [ -n "$VERSION" ] || fatal "Can't get version for $PKGNAME"
fi

PKG=$PKGNAME-$VERSION.tar
pack_tar $PKG opt/$PKGNAME/$BINNAME

epm install --repack "$PKG" || exit

echo
echo "Note: run
# serv $PKGNAME on
to enable and start $PKGNAME system service
"
