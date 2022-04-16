#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT="$(grep "^Name: " $SPEC | sed -e "s|Name: ||g" | head -n1)"
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# move package to /opt
ROOTDIR=$(basename $(find $BUILDROOT -mindepth 1 -maxdepth 1 -type d))
mkdir -p $BUILDROOT/opt
mv $BUILDROOT/$ROOTDIR $BUILDROOT$PRODUCTDIR
subst "s|\"/$ROOTDIR/|\"$PRODUCTDIR/|" $SPEC

fix_chrome_sandbox

cd $BUILDROOT$PRODUCTDIR
DESKTOPFILE="$(echo *.desktop | head -n1)"
ICONFILE="$(cat $DESKTOPFILE | grep "^Icon" | head -n1 | sed -e 's|Icon=||').png"

mkdir -p $BUILDROOT/usr/share/applications/
cat $DESKTOPFILE | sed -e "s|AppRun|$PRODUCT|" > $BUILDROOT/usr/share/applications/$DESKTOPFILE
pack_file /usr/share/applications/$DESKTOPFILE

mkdir -p $BUILDROOT/usr/share/pixmaps/
cp $ICONFILE $BUILDROOT/usr/share/pixmaps/
pack_file /usr/share/pixmaps/kontur-talk.png

cd - >/dev/null

add_bin_exec_command $PRODUCT $PRODUCTDIR/AppRun
