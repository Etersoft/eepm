#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"
PRODUCT=koharu

. $(dirname $0)/common.sh

if [ -f "$BUILDROOT$PRODUCTDIR/AppRun" ] ; then
    # Upstream marks bundled documentation as executable.
    ignore_library_path "$PRODUCTDIR/share"
    add_bin_cdexec_command $PRODUCT $PRODUCTDIR/AppRun
    subst "2iexport APPDIR=$PRODUCTDIR" "$BUILDROOT/usr/bin/$PRODUCT"
    # bin/* and AppRun are hard links to sharun; the actual helper is in shared/.
    fix_chrome_sandbox "$PRODUCTDIR/shared/bin/chrome-sandbox"
    exit 0
fi

move_to_opt /usr/share/$PRODUCT
remove_file /usr/bin/$PRODUCT
add_bin_exec_command

# Koharu embeds Chromium via CEF.
fix_chrome_sandbox
