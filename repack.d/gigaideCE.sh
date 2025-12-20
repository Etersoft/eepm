#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Development/C|" $SPEC
#subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: https://gitverse.ru/services/gigaide|" $SPEC
subst "s|^Summary:.*|Summary: GigaIDE Desktop Community Edition|" $SPEC

move_to_opt "/gigaide-CE-*"
# use native launcher as recommended
add_bin_link_command $PRODUCT $PRODUCTDIR/bin/idea

wmClass="$(get_json_value .$PRODUCTDIR/product-info.json '["launch",0,"startupWmClass"]')"
[ -n "$wmClass" ] || wmClass="$PRODUCT"

cat <<EOF | create_file /usr/share/applications/$wmClass.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=GigaIDE Desktop Community Edition
Comment=GigaIDE
Exec=$PRODUCT %f
Icon=$PRODUCT
Terminal=false
StartupNotify=true
StartupWMClass=$wmClass
Categories=Development;IDE;
EOF

install_file $PRODUCTDIR/bin/idea.png /usr/share/pixmaps/$PRODUCT.png
install_file $PRODUCTDIR/bin/idea.svg /usr/share/pixmaps/$PRODUCT.svg

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

