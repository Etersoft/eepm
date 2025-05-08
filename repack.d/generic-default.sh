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

pd="$(echo $BUILDROOT/*)"
if [ -d "$pd" ] ; then
    bn="$(basename "$pd")"
    if [ "$bn" != "usr" ] && [ "$bn" != "opt" ] ; then
        move_to_opt "/$bn"
    fi
else
    flag_dir=
    for i in $pd ; do
        [ -d "$i" ] && flag_dir=1 && break
    done
    if [ -z "$flag_dir" ] ; then
        # only a few files in the root
        move_to_opt "/"
    fi
fi

# FIXME: hack for nonstandart name
pd="$(echo $BUILDROOT/opt/*)"
[ -d "$pd" ] && PRODUCTDIR="/opt/$(basename "$pd")"

if [ -f "$BUILDROOT$PRODUCTDIR/$PRODUCT" ] ; then
    add_bin_exec_command
fi

for desktopfile in $BUILDROOT/usr/share/applications/*.desktop ; do
    [ -f "$desktopfile" ] || continue
    EXEC="$(get_desktop_value "$desktopfile" "Exec")"
    # replace /opt path with command name only
    if [ "/usr/bin/$(basename "$EXEC")" = "/usr/bin/$PRODUCT" ] || [ "$EXEC" = "$PRODUCTDIR/$PRODUCT" ] ; then
        if [ -x $BUILDROOT/usr/bin/$PRODUCT ] ; then
            fix_desktop_file "$EXEC"
        fi
    fi
done

# TODO: add product dir detection
if [ -f "$BUILDROOT$PRODUCTDIR/v8_context_snapshot.bin" ] ; then
    echo "electron based application detected, adding requires for it ..."
    add_electron_deps
    fix_chrome_sandbox
fi
