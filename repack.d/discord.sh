#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=discord
LIBDIR=/opt

mkdir -p $BUILDROOT$LIBDIR/
mv $BUILDROOT/usr/share/$PRODUCT/ $BUILDROOT$LIBDIR/$PRODUCT/
subst "s|/usr/share/$PRODUCT|$LIBDIR/$PRODUCT|g" $SPEC

subst '1iAutoProv:no' $SPEC

# usual command skype
mkdir -p $BUILDROOT/usr/bin/
ln -sf $LIBDIR/$PRODUCT/Discord $BUILDROOT/usr/bin/$PRODUCT
subst "s|/usr/share/discord/Discord|/usr/bin/$PRODUCT|g" $BUILDROOT/$LIBDIR/$PRODUCT/discord.desktop
ln -sf $LIBDIR/$PRODUCT/discord.desktop $BUILDROOT/usr/share/applications/discord.desktop
ln -sf $LIBDIR/$PRODUCT/discord.png $BUILDROOT/usr/share/pixmaps/discord.png
