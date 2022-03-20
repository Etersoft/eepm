#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=discord
LIBDIR=/opt
PRODUCTDIR=/opt/$PRODUCT

mkdir -p $BUILDROOT$LIBDIR/
mv $BUILDROOT/usr/share/$PRODUCT/ $BUILDROOT$PRODUCTDIR/
subst "s|/usr/share/$PRODUCT|$PRODUCTDIR|g" $SPEC

subst '1iAutoProv:no' $SPEC

# usual command skype
mkdir -p $BUILDROOT/usr/bin/
ln -sf $PRODUCTDIR/Discord $BUILDROOT/usr/bin/$PRODUCT
subst "s|/usr/share/discord/Discord|/usr/bin/$PRODUCT|g" $BUILDROOT/$PRODUCTDIR/discord.desktop
ln -sf $PRODUCTDIR/discord.desktop $BUILDROOT/usr/share/applications/discord.desktop
ln -sf $PRODUCTDIR/discord.png $BUILDROOT/usr/share/pixmaps/discord.png
