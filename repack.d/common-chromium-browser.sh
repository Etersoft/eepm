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
    subst '1iAutoProv: no' $SPEC

    # remove cron update
    remove_file /etc/cron.daily/$PRODUCTCUR
    remove_file /etc/cron.daily/$PRODUCT

    # remove unsupported file
    remove_file /usr/share/menu/$PRODUCT.menu
    remove_file /usr/share/menu/$PRODUCTCUR.menu
}


install_deps()
{
    # install all requires packages before packing (the list have got with rpmreqs package | xargs echo)
    install_requires at-spi2-atk file GConf glib2 grep libatk libat-spi2-core libalsa libcairo libcups libdbus libdrm libexpat libgbm libgdk-pixbuf libgio libgtk+3 libnspr libnss libpango \
            libX11 libxcb libXcomposite libXcursor libXdamage libXext libXfixes libXi libXrandr libXrender libXtst sed which xdg-utils xprop libsecret
}

add_deps()
{
    [ "$(epm print info -s)" = "alt" ] || return
    add_requires at-spi2-atk file GConf glib2 grep libatk libat-spi2-core libalsa libcairo libcups libdbus libdrm libexpat libgbm libgdk-pixbuf libgio libgtk+3 libnspr libnss libpango
    add_requires libX11 libxcb libXcomposite libXcursor libXdamage libXext libXfixes libXi libXrandr libXrender libXtst sed which xdg-utils xprop libsecret
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

