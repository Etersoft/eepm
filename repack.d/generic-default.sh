#!/bin/sh -x

# Default repack script (used if a special script for target product is missed)

# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT="$3"
PKG="$4"

. $(dirname $0)/common.sh

# detect requires by libs (skip Full AppImage bundle)
if [ ! -f "$BUILDROOT$PRODUCTDIR/.bundle.yml" ] ; then
    add_libs_requires
fi

# FIXME: hack for nonstandart name
pd="$(echo $BUILDROOT/opt/*)"
[ -d "$pd" ] && PRODUCTDIR="/opt/$(basename "$pd")"

if [ -f "$BUILDROOT$PRODUCTDIR/$PRODUCT" ] ; then
    add_bin_exec_command
fi

if [ -f $BUILDROOT/usr/share/applications/*.desktop ] ; then
    EXEC="$(cat $BUILDROOT/usr/share/applications/*.desktop | grep "^Exec=" | head -n1 | sed -e 's|Exec=||' -e 's| .*||')"
    if [ "/usr/bin/$(basename "$EXEC")" = "/usr/bin/$PRODUCT" ] || [ "$EXEC" = "$PRODUCTDIR/$PRODUCT" ] ; then
        if [ -x $BUILDROOT/usr/bin/$PRODUCT ] ; then
            fix_desktop_file "$EXEC"
        fi
    fi
fi

# TODO: add product dir detection
if [ -f "$BUILDROOT$PRODUCTDIR/v8_context_snapshot.bin" ] ; then
    echo "electron based application detected, adding requires for it ..."
    add_electron_deps
    fix_chrome_sandbox
fi
