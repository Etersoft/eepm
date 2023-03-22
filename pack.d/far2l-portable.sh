#!/bin/sh

TAR="$1"
#VERSION="$2"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

VERSION="2.4"

[ -n "$VERSION" ] || fatal "Missed archive version"

CURDIR=$(pwd)

PRODUCTNAME=far2l-portable
PRODUCTCUR=far2l
PKGNAME=$CURDIR/$PRODUCTNAME-$VERSION.tar

tdir=$(mktemp -d)
trap "rm -fr $tdir" EXIT
cd $tdir || fatal

# TODO: embed erc to epm
epm assure erc || epm ei erc || fatal

if echo "$TAR" | grep -q "far2l_portable.*.tar.gz" ; then
    erc $TAR || fatal
    RUNFILE="$(echo $tdir/far2l*.run)"
elif echo "$TAR" | grep -q "far2l_portable.*.run" ; then
    RUNFILE="$TAR"
fi

[ -s "$RUNFILE" ] || fatal "Missed $RUNFILE"

mkdir -p $tdir/opt/$PRODUCTNAME/

sh $RUNFILE --noexec --target $tdir/opt/$PRODUCTNAME || fatal

#mkdir -p $tdir/usr/bin/
#ln -s /opt/$PRODUCTNAME/$PRODUCTCUR $tdir/usr/bin/$PRODUCTCUR

#erc pack $PKGNAME opt/$PRODUCTNAME usr/bin/ || fatal
erc pack $PKGNAME opt/$PRODUCTNAME || fatal

return_tar "$PKGNAME"
