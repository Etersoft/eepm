#!/bin/sh -x
# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=spravki-bk
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# Remove problematic directory with CR character in name
remove_dir "$PRODUCTDIR/resources/bin/%sbk-cleaner-path%"$'\r'

# Install proper icon
remove_file /usr/share/applications/sbk.desktop
install_file $PRODUCTDIR/resources/bin/ClientApp/build/logo.svg /usr/share/icons/hicolor/scalable/apps/$PRODUCT.svg

# Create binary link for command line execution
add_bin_link_command $PRODUCT $PRODUCTDIR/sbk

add_electron_deps

# Remove incorrect desktop file
remove_file /usr/share/applications/sbk.desktop

# Create proper desktop file
cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=СПО "Справки БК"
Comment=Система подготовки отчетности "Справки БК"
Icon=$PRODUCT
Exec=$PRODUCT
Categories=Office;
Terminal=false
EOF

# Add libgdiplus dependency
add_unirequires libgdiplus.so.0

# Create symbolic link for libgdiplus.so.0 in product directory
ln -sf /usr/lib64/libgdiplus.so.0 ./$PRODUCTDIR/resources/bin/libgdiplus.so
pack_file $PRODUCTDIR/resources/bin/libgdiplus.so

