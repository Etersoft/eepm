#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PRODUCT=teams
LIBDIR=/opt
PRODUCTDIR=/opt/teams

. $(dirname $0)/common-chromium-browser.sh

if [ "$(epm print info -e)" = "ALTLinux/p8" ] ; then
    # drop unsupported binary
    #subst '1i%filter_from_requires /^libm.so.6(GLIBC_2.27).*/d' $SPEC
    rm -rf $BUILDROOT/usr/share/teams/resources/app.asar.unpacked/node_modules/@microsoft/fasttext-languagedetector/build/
    subst "s|.*/usr/share/teams/resources/app.asar.unpacked/node_modules/@microsoft/fasttext-languagedetector/build/.*||" $SPEC
fi

# move to more correct place
subst "s|^TEAMS_PATH=.*|$LIBDIR/$PRODUCT/teams|" $BUILDROOT/usr/bin/teams
mkdir -p $BUILDROOT/$LIBDIR
mv -v $BUILDROOT/usr/share/teams/ $BUILDROOT/$LIBDIR/
subst "s|/usr/share/teams|$LIBDIR/$PRODUCT|" $SPEC

fix_chrome_sandbox

add_electron_deps

fix_desktop_file /usr/bin/teams

