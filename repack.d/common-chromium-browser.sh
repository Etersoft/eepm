#!/bin/sh

# common functions for repack chromium based browsers
# used BUILDROOT, SPEC, PRODUCT, PRODUCTCUR and PRODUCTDIR variables
# example
# PRODUCT=mybrowser
# PRODUCTCUR=mybrowser-nightly
# PRODUCTDIR=/opt/my/browser

. $(dirname $0)/common.sh

set_alt_alternatives()
{
    local priority="$1"
    # needed alternatives
    subst '1iProvides: webclient' $SPEC
# FIXME: it have to be generated via /usr/lib/rpm/alternatives.prov ?
# TODO for eepm-rpm-build (ordinal rpm-build works fine with it):
# error: line 1: Versioned file name not permitted: Provides: /usr/bin/x-www-browser = 65
#    subst "1iProvides: /usr/bin/xbrowser = $priority" $SPEC
#    subst "1iProvides: /usr/bin/x-www-browser = $priority" $SPEC
    subst "1iProvides: /usr/bin/xbrowser" $SPEC
    subst "1iProvides: /usr/bin/x-www-browser" $SPEC

    subst "s|%files|%files\n/etc/alternatives/packages.d/$PRODUCT|" $SPEC
    mkdir -p $BUILDROOT/etc/alternatives/packages.d/
    cat <<EOF >$BUILDROOT/etc/alternatives/packages.d/$PRODUCT
/usr/bin/xbrowser	/usr/bin/$PRODUCT	$priority
/usr/bin/x-www-browser	/usr/bin/$PRODUCT	$priority
EOF
}


copy_icons_to_share()
{
    local iconname=$PRODUCT

    # try get icon name from desktopfile
    local desktopfile=$BUILDROOT/usr/share/applications/$PRODUCT.desktop
    [ -r $desktopfile ] || desktopfile=$BUILDROOT/usr/share/applications/$PRODUCTCUR.desktop
    if [ -r $desktopfile ] ; then
        iconname="$(cat $desktopfile | grep "^Icon" | head -n1 | sed -e 's|Icon=||')"
    fi

    for i in 16 24 32 48 64 128 256 ; do
        [ -r $BUILDROOT/$PRODUCTDIR/product_logo_$i*.png ] || continue
        mkdir -p $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/
        cp $BUILDROOT/$PRODUCTDIR/product_logo_$i*.png $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png
    done

    subst "s|%files|%files\n/usr/share/icons/hicolor/*x*/apps/$iconname.png|" $SPEC
}


cleanup()
{
    # remove cron update
    remove_file /etc/cron.daily/$PRODUCTCUR
    remove_file /etc/cron.daily/$PRODUCT

    # remove unsupported file
    remove_file /usr/share/menu/$PRODUCT.menu
    remove_file /usr/share/menu/$PRODUCTCUR.menu
}

add_chromium_deps()
{
    fix_chrome_sandbox

    fix_chrome_crashpad

    # Qt shim libraries (libqt5_shim.so, libqt6_shim.so) are optional for native file dialogs.
    # Browsers work fine with GTK dialogs when Qt is not available.
    # Only ignore Qt requires when shim libs are detected in the package.
    # TODO: implement ignoring requires for explicitly specified libraries
    [ -f "$BUILDROOT$PRODUCTDIR/libqt5_shim.so" ] && ignore_lib_requires 'libQt5.*'
    [ -f "$BUILDROOT$PRODUCTDIR/libqt6_shim.so" ] && ignore_lib_requires 'libQt6.*'

    add_unirequires "file grep sed which xdg-utils"
}


# FIXME: too many heruistic due https://bugzilla.altlinux.org/42189
add_bin_commands()
{
    mkdir -p $BUILDROOT/usr/bin/

    if [ -L $BUILDROOT/usr/bin/$PRODUCTCUR ] ; then
        rm -fv $BUILDROOT/usr/bin/$PRODUCTCUR
    else
        subst "s|%files|%files\n/usr/bin/$PRODUCTCUR|" $SPEC
    fi

    if [ -r $BUILDROOT$PRODUCTDIR/$PRODUCTCUR ] ; then
        ln -rs $BUILDROOT$PRODUCTDIR/$PRODUCTCUR $BUILDROOT/usr/bin/$PRODUCTCUR
    else
        ln -rs $BUILDROOT$PRODUCTDIR/$PRODUCT $BUILDROOT/usr/bin/$PRODUCTCUR
    fi

    # fix links in $PRODUCTDIR (may be broken due https://bugzilla.altlinux.org/42189)
    if [ ! -r $BUILDROOT$(readlink $BUILDROOT$PRODUCTDIR/$PRODUCT) ] ; then
        rm -fv $BUILDROOT$PRODUCTDIR/$PRODUCT
        ln -s $PRODUCTCUR $BUILDROOT$PRODUCTDIR/$PRODUCT
    fi

    # short command for run
    add_bin_link_command $PRODUCT $PRODUCTCUR
}
