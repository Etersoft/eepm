#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

PRODUCTCUR=far2l

. $(dirname $0)/common.sh


[ -n "$VERSION" ] || fatal "Missed archive version"

CURDIR=$(pwd)

PKGNAME=$CURDIR/$PRODUCT-$VERSION.tar

tdir=$(mktemp -d)
trap "rm -fr $tdir" EXIT
cd $tdir || fatal

if echo "$TAR" | grep -q "far2l_portable.*.tar.gz" ; then
    erc $TAR || fatal
    RUNFILE="$(echo $tdir/far2l*.run)"
elif echo "$TAR" | grep -q "far2l_portable.*.run" ; then
    RUNFILE="$TAR"
fi

[ -s "$RUNFILE" ] || fatal "Missed $RUNFILE"

mkdir -p $tdir/opt/$PRODUCT/

sh $RUNFILE --noexec --target $tdir/opt/$PRODUCT || fatal

#mkdir -p $tdir/usr/bin/
#ln -s /opt/$PRODUCT/$PRODUCTCUR $tdir/usr/bin/$PRODUCTCUR

#erc pack $PKGNAME opt/$PRODUCT usr/bin/ || fatal
erc pack $PKGNAME opt/$PRODUCT || fatal

return_tar "$PKGNAME"
