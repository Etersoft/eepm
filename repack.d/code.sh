#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=code
PRODUCTDIR=/opt/$PRODUCT

mkdir -p $BUILDROOT/opt
mv $BUILDROOT/usr/share/$PRODUCT/ $BUILDROOT$PRODUCTDIR/
subst "s|/usr/share/$PRODUCT|$PRODUCTDIR|g" $SPEC

subst '1iAutoReq:yes,nomonolib,nomono' $SPEC
subst '1iAutoProv:no' $SPEC

subst "s|\(.*$PRODUCTDIR/code.*\)|/usr/bin/code\n/usr/bin/vscode\n\1|" $SPEC

mkdir -p $BUILDROOT/usr/bin/
ln -rs $BUILDROOT$PRODUCTDIR/bin/code $BUILDROOT/usr/bin/code
ln -rs $BUILDROOT$PRODUCTDIR/bin/code $BUILDROOT/usr/bin/vscode

# install all requires packages before packing (the list have got with rpmreqs package | xargs echo)
epm install --skip-installed at-spi2-atk coreutils findutils gawk glib2 libalsa libatk libat-spi2-core libcairo libdbus libdrm libexpat libgbm libgdk-pixbuf libgio libgtk+3 libnspr libnss libpango libsecret libX11 libxcb libXcomposite libXcursor libXdamage libXext libXfixes libXi libxkbfile libXrandr libXrender libXScrnSaver libXtst sed
