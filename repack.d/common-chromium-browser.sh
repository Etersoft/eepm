#!/bin/sh

# common functions for repack chromium based browsers
# used BUILDROOT, SPEC, PRODUCT, PRODUCTCUR and PRODUCTDIR variables
# example
# PRODUCT=mybrowser
# PRODUCTCUR=mybrowser-nightly
# PRODUCTDIR=/opt/my/browser

set_alt_alternatives()
{
    local priority="$1"
    # needed alternatives
    subst '1iProvides:webclient' $SPEC

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
    subst '1iAutoProv:no' $SPEC

    # remove cron update
    if [ -r $BUILDROOT/etc/cron.daily/$PRODUCTCUR ] ; then
        rm -f $BUILDROOT/etc/cron.daily/$PRODUCTCUR
        subst 's|.*/etc/cron.daily/.*||' $SPEC
    fi

    if [ -r $BUILDROOT/etc/cron.daily/$PRODUCT ] ; then
        rm -f $BUILDROOT/etc/cron.daily/$PRODUCT
        subst 's|.*/etc/cron.daily/.*||' $SPEC
    fi

    # remove unsupported file
    if [ -r $BUILDROOT/usr/share/menu/*.menu ] ; then
        rm -f $BUILDROOT/usr/share/menu/*.menu
        subst "s|.*/usr/share/menu/.*.menu.*||" $SPEC
    fi

}


use_system_xdg()
{
    # replace embedded xdg tools
    for i in $PRODUCTDIR/{xdg-mime,xdg-settings} ; do
        [ -s $BUILDROOT$i ] || continue
        rm -v $BUILDROOT$i
        ln -s /usr/bin/$(basename $i) $BUILDROOT$i
    done
}


install_deps()
{
    # install all requires packages before packing (the list have got with rpmreqs package | xargs echo)
    epm install --skip-installed at-spi2-atk file gawk GConf glib2 grep libatk libat-spi2-core libcairo libcups libdbus libdrm libexpat libgbm libgdk-pixbuf libgio libgtk+3 libnspr libnss libpango \
            libX11 libxcb libXcomposite libXcursor libXdamage libXext libXfixes libXi libXrandr libXrender libXtst sed tar which xdg-utils xprop
}


add_bin_commands()
{
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

    # fix links
    if [ ! -r $BUILDROOT$(readlink $BUILDROOT$PRODUCTDIR/$PRODUCT) ] ; then
        rm -fv $BUILDROOT$PRODUCTDIR/$PRODUCT
        ln -s $PRODUCTCUR $BUILDROOT$PRODUCTDIR/$PRODUCT
    fi

    # short command for run
    if [ ! -r $BUILDROOT/usr/bin/$PRODUCT ] ; then
        ln -s $PRODUCTCUR $BUILDROOT/usr/bin/$PRODUCT
        subst "s|%files|%files\n/usr/bin/$PRODUCT|" $SPEC
    fi
}
