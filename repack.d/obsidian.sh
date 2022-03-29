#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=obsidian
PRODUCTCUR=obsidian
PRODUCTDIR=/opt/Obsidian


. $(dirname $0)/common-chromium-browser.sh

cleanup

#add_bin_commands

if [ ! -f "$BUILDROOT/usr/bin/$PRODUCT" ] ; then
    mkdir -p $BUILDROOT/usr/bin
    subst "s|%files|%files\n%_bindir/$PRODUCT|" $SPEC
    # fix lib.req: ERROR: /tmp/.private/lav/tmp.lPI2zBE3UA/obsidian_0.13.31_amd64.deb.tmpdir/obsidian-0.13.31/usr/bin/obsidian: library libffmpeg.so not found
    echo "exec $PRODUCTDIR/$PRODUCT" > $BUILDROOT/usr/bin/$PRODUCT
    chmod a+x $BUILDROOT/usr/bin/$PRODUCT
fi


install_deps

fix_chrome_sandbox

#epm assure patchelf || exit
#for i in $BUILDROOT$PRODUCTDIR/$PRODUCT ; do
#    a= patchelf --set-rpath "$PRODUCTDIR" $i
#done
