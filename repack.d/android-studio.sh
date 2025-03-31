#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Development/C|" $SPEC
#subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: https://developer.android.com/studio|" $SPEC
subst "s|^Summary:.*|Summary: The official Android IDE|" $SPEC

move_to_opt "/android-studio*"

orig="studio"
# use native launcher as recommended
add_bin_link_command $PRODUCT $PRODUCTDIR/bin/$orig

# file fieldstring
get_json_value()
{
    [ -s "$1" ] || fatal "Missed $1 file"
    epm tool json -b < "$1" | grep -m1 -F "$2" | sed -e 's|.*[[:space:]]||' | sed -e 's|"||g'
}

wmClass="$(get_json_value .$PRODUCTDIR/product-info.json '["launch",0,"startupWmClass"]')"
[ -n "$wmClass" ] || wmClass="$PRODUCT"

cat <<EOF | create_file /usr/share/applications/$wmClass.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=The official Android IDE
Comment=Android Studio
Exec=$PRODUCT %f
Icon=$PRODUCT
Terminal=false
StartupNotify=true
StartupWMClass=$wmClass
Categories=Development;IDE;
EOF

install_file $PRODUCTDIR/bin/$orig.png /usr/share/pixmaps/$PRODUCT.png
install_file $PRODUCTDIR/bin/$orig.svg /usr/share/pixmaps/$PRODUCT.svg

# kind of hack
subst 's|%dir "'$PRODUCTDIR'/"||' $SPEC
subst 's|%dir "'$PRODUCTDIR'/bin/"||' $SPEC
subst 's|%dir "'$PRODUCTDIR'/lib/"||' $SPEC
subst 's|%dir "'$PRODUCTDIR'/plugins/"||' $SPEC

#subst 's|%dir "'$PRODUCTDIR'/plugins/webp"||' $SPEC
#subst 's|%dir "'$PRODUCTDIR'/plugins/webp/lib"||' $SPEC

pack_dir $PRODUCTDIR/
pack_dir $PRODUCTDIR/bin/
pack_dir $PRODUCTDIR/lib/
pack_dir $PRODUCTDIR/plugins/

#pack_dir $PRODUCTDIR/plugins/webp
#pack_dir $PRODUCTDIR/plugins/webp/lib

ignore_library_path $PRODUCTDIR/plugins/android/resources
add_libs_requires
