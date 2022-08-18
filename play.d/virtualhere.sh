#!/bin/sh

PKGNAME=virtualhere
PRODUCTDIR=/opt/$PKGNAME
BINNAME=vhusbd
SUPPORTEDARCHES="x86_64 armhf mips mipsel aarch64 x86"
DESCRIPTION='Generic VirtualHere USB Server from the official site'

. $(dirname $0)/common.sh

arch="$($DISTRVENDOR -a)"
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

pkgtype="$($DISTRVENDOR -p)"

tdir=$(mktemp -d)
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

VERSION="$(epm tool eget -O- https://virtualhere.com/usb_server_software | grep "<b>Version [0-9.]*</b>" | sed -e 's|.*<b>Version \([0-9.]*\)</b>.*|\1|')"
[ -n "$VERSION" ] || fatal "Can't get version for $PKGNAME"
PKG=$PKGNAME-$VERSION.tar
pack_tar $PKG opt/$PKGNAME/$BINNAME

epm install --repack "$PKG"
RES=$?

rm -rf $tdir

[ "$RES" = "0" ] || exit $RES

echo
echo "Note: run
# serv $PKGNAME on
to enable and start $PKGNAME system service
"

