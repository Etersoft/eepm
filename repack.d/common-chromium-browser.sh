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


remove_file()
{
    local file="$1"
    [ -f $BUILDROOT/$file ] || return

    rm -fv $BUILDROOT/$file
    subst "s|.*$file.*||" $SPEC
}

cleanup()
{
    subst '1iAutoProv:no' $SPEC

    # remove cron update
    remove_file /etc/cron.daily/$PRODUCTCUR
    remove_file /etc/cron.daily/$PRODUCT

    # remove unsupported file
    remove_file /usr/share/menu/$PRODUCT.menu
    remove_file /usr/share/menu/$PRODUCTCUR.menu
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
    epm install --skip-installed at-spi2-atk file GConf glib2 grep libatk libat-spi2-core libcairo libcups libdbus libdrm libexpat libgbm libgdk-pixbuf libgio libgtk+3 libnspr libnss libpango \
            libX11 libxcb libXcomposite libXcursor libXdamage libXext libXfixes libXi libXrandr libXrender libXtst sed which xdg-utils xprop
}


pack_file()
{
    grep -q "^$1$" $SPEC && return
    grep -q "\"$1\"" $SPEC && return
    subst "s|%files|%files\n$1|" $SPEC
}


add_bin_link_command()
{
    local name="$1"
    local target="$2"
    [ -n "$name" ] || name="$PRODUCT"
    [ -n "$target" ] || target="$PRODUCTDIR/$name"
    [ -e $BUILDROOT/usr/bin/$name ] && return

    mkdir -p $BUILDROOT/usr/bin/
    ln -s $target $BUILDROOT/usr/bin/$name
    pack_file /usr/bin/$name
}


add_bin_exec_command()
{
    local name="$1"
    local target="$2"
    [ -n "$name" ] || name="$PRODUCT"
    [ -n "$target" ] || target="$PRODUCTDIR/$name"
    [ -e $BUILDROOT/usr/bin/$name ] && return

    mkdir -p $BUILDROOT/usr/bin/
    echo "exec $target \"\$@\"" > $BUILDROOT/usr/bin/$name
    chmod 0755 $BUILDROOT/usr/bin/$name
    pack_file /usr/bin/$name
}


# FIXME: too many heruistic due https://bugzilla.altlinux.org/42189
add_bin_commands()
{
    mkdir -p $BUILDROOT/usr/bin

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

move_to_opt()
{
    local from="$1"
    [ -n "$from" ] || from="/usr/share/$PRODUCT"
    mkdir -p $BUILDROOT$PRODUCTDIR/
    mv $BUILDROOT/$from/* $BUILDROOT$PRODUCTDIR/
    subst "s|$from|$PRODUCTDIR|g" $SPEC
}



fix_chrome_sandbox()
{
    local sandbox="$1"
    # Set SUID for chrome-sandbox if userns_clone is not supported
    userns_path='/proc/sys/kernel/unprivileged_userns_clone'
    userns_val="$(cat $userns_path 2>/dev/null)"
    [ "$userns_val" = '1' ] && return
    [ -n "$sandbox" ] || sandbox=$PRODUCTDIR/chrome-sandbox
    chmod 4755 $BUILDROOT/$sandbox
}
