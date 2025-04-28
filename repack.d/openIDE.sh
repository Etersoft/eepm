#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"

PRODUCT=openide
PRODUCTCUR=openIDE

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Development/Tools|" $SPEC
subst "s|^URL:.*|URL: https://openide.ru/|" $SPEC
subst "s|^Summary:.*|Summary: openIDE - Free IDE based on IntelliJ IDEA Community Edition|" $SPEC

move_to_opt "/$PRODUCTCUR-*"

add_bin_link_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT.sh
add_bin_link_command $PRODUCTCUR $PRODUCT

wmClass="$(get_json_value $PRODUCTDIR/product-info.json '["launch",0,"startupWmClass"]')"
[ -n "$wmClass" ] || wmClass="$PRODUCT"

cat <<EOF | create_file /usr/share/applications/$wmClass.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=openIDE
Comment=Free IDE based on IntelliJ IDEA Community Edition
Exec=$PRODUCT %f
Icon=$PRODUCT
Terminal=false
StartupNotify=true
StartupWMClass=$wmClass
Categories=Development;IDE;
EOF

install_file $PRODUCTDIR/bin/$PRODUCT.png /usr/share/pixmaps/$PRODUCT.png
#install_file $PRODUCTDIR/bin/$PRODUCT.svg /usr/share/icons/hicolor/scalable/apps/$PRODUCT.svg

subst 's|%dir "'$PRODUCTDIR'/"||' $SPEC
subst 's|%dir "'$PRODUCTDIR'/bin/"||' $SPEC
subst 's|%dir "'$PRODUCTDIR'/lib/"||' $SPEC
subst 's|%dir "'$PRODUCTDIR'/plugins/"||' $SPEC

pack_dir $PRODUCTDIR/
pack_dir $PRODUCTDIR/bin/
pack_dir $PRODUCTDIR/lib/
pack_dir $PRODUCTDIR/plugins/

add_libs_requires
