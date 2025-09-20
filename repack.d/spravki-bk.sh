#!/bin/sh -x
# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=spravki-bk
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# Fix problematic directory with CR character in name
cd "$BUILDROOT$PRODUCTDIR/resources/bin/" || exit 1
if [ -d "%sbk-cleaner-path%"$'\r' ]; then
    mv "%sbk-cleaner-path%"$'\r' "%sbk-cleaner-path%"
fi

# Replace paths with \r in SPEC file
sed -i 's|%sbk-cleaner-path%\r|%sbk-cleaner-path%|g' "$SPEC"

# Remove incorrect desktop file and install proper icon
remove_file /usr/share/applications/sbk.desktop
install_file $PRODUCTDIR/resources/bin/ClientApp/build/logo.svg /usr/share/icons/hicolor/scalable/apps/$PRODUCT.svg

# Create binary link for command line execution
add_bin_link_command $PRODUCT $PRODUCTDIR/sbk

# Set correct permissions for chrome-sandbox (SUID bit required)
fix_chrome_sandbox $PRODUCTDIR/chrome-sandbox

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
ln -sf /usr/lib64/libgdiplus.so.0 $PRODUCTDIR/resources/bin/libgdiplus.so

add_libs_requires
