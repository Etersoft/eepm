#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=firefox

PRODUCTCUR=$(basename $0 .sh)
PRODUCTDIR=/opt/$PRODUCTCUR

PREINSTALL_PACKAGES="fontconfig glib2 libalsa libatk libcairo libcairo-gobject libdbus libdbus-glib libfreetype libgdk-pixbuf libgio libgtk+3 libharfbuzz libpango libX11 libxcb libXcomposite libXcursor libXdamage libXext libXfixes libXi libXrandr libXrender libXtst"

. $(dirname $0)/common-chromium-browser.sh

#for i in firefox firefox-devel ; do
#    [ "$i"  = "$PRODUCTCUR" ] && continue
#    subst "1iConflicts:$i" $SPEC
#done

# set_autoreq 'yes,noshell,nomonolib,nomono,nopython'
add_libs_requires

#set_alt_alternatives 65

move_to_opt /usr/lib/$PRODUCTCUR

rm -f $BUILDROOT/usr/bin/$PRODUCTCUR
add_bin_link_command $PRODUCTCUR $PRODUCTDIR/$PRODUCT
#add_bin_link_command

copy_icons_to_share()
{
    local iconname=$PRODUCT

    # try get icon name from desktopfile
    local desktopfile=$BUILDROOT/usr/share/applications/$PRODUCT.desktop
    [ -r $desktopfile ] || desktopfile=$BUILDROOT/usr/share/applications/$PRODUCTCUR.desktop
    if [ -r $desktopfile ] ; then
        iconname="$(cat $desktopfile | grep "^Icon" | head -n1 | sed -e 's|Icon=||')"
    fi

    for i in 16 32 48 64 128 ; do
        sicon=$BUILDROOT$PRODUCTDIR/browser/chrome/icons/default/default$i.png
        [ -r $sicon ] || continue
        mkdir -p $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/
        rm -f $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png
        cp $sicon $BUILDROOT/usr/share/icons/hicolor/${i}x${i}/apps/$iconname.png
    done

    #subst "s|%files|%files\n/usr/share/icons/hicolor/*x*/apps/$iconname.png|" $SPEC
}

copy_icons_to_share

if epm assure patchelf ; then
for i in $BUILDROOT/$PRODUCTDIR/{lib*.so,plugin-container} ; do
    a= patchelf --set-rpath '$ORIGIN/' $i || continue
done

for i in $BUILDROOT/$PRODUCTDIR/gmp-clearkey/0.1/lib*.so ; do
    a= patchelf --set-rpath '$ORIGIN/../../' $i || continue
done
fi
