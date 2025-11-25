#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCTDIR=/opt/kingsoft/wps-office
PKGNAME=$(basename $0 .sh)

. $(dirname $0)/common.sh

#REQUIRES="fonts-ttf-liberation, fonts-ttf-dejavu"
if [ "$PKGNAME" = "wps-office-cn" ] ; then
    subst "s|^\(Name: .*\)$|Name: $PKGNAME|" $SPEC
    add_conflicts wps-office
fi

remove_dir /etc/cron.d
remove_dir /etc/logrotate.d
remove_dir /etc/xdg

# ALT bug 43751
remove_file /usr/share/desktop-directories/wps-office.directory

# ALT bug 45683
remove_file $PRODUCTDIR/office6/wpscloudsvr

# linked with missed libkappessframework.so()(64bit)
remove_file $PRODUCTDIR/office6/addons/pdfbatchcompression/libpdfbatchcompressionapp.so

# https://github.com/NixOS/nixpkgs/commit/da74ad3a905aa45ee6e4f8b4b69b56930195adcb
# Use system libjpeg
remove_file "$PRODUCTDIR/office6/libjpeg.so*"

# Fix theme system on WPS Office 11
is_stdcpp_enough "12.1" && remove_file "$PRODUCTDIR/office6/libstdc++.so*"

# hack to fix bug somewhere in linking
ignore_lib_requires "libc++.so"

# avoid dependency to Qt 4
remove_file $PRODUCTDIR/office6/librpcwpsapi.so
remove_file $PRODUCTDIR/office6/librpcwppapi.so
remove_file $PRODUCTDIR/office6/librpcetapi.so

# WPS Office provide libuof.so()(64bit) itself
ignore_lib_requires "libuof.so"

# Optional distribution-specific libraries
# libmysqlclient.so.18 - required by libFontWatermark.so for database connectivity in font watermarking features
# libpeony.so.3 - required by libpeony-wpsprint-menu-plugin.so for Peony file manager print menu integration
ignore_lib_requires "libmysqlclient.so.18"
ignore_lib_requires "libpeony.so.3"

# Fix wps deprecated python2 command
# https://aur.archlinux.org/cgit/aur.git/tree/fix-wps-python-parse.patch?h=wps-office-cn
subst 's/python -c '\''import sys, urllib; print urllib.unquote(sys.argv\[1\])'\''/python3 -c '\''import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))'\''/' $BUILDROOT/usr/bin/wps

# ошибка: Macro %20sequence not found
remove_file $PRODUCTDIR/office6/mui/zh_CN/resource/help/etrainbow/images/Ribbon/custom_%20sequence.gif
#remove_dir $PRODUCTDIR/office6/mui/zh_CN/resource/help/etrainbow/images

# Fix desktop file categories
fix_desktop_categories() {
    local file_pattern="$1"
    local categories="$2"
    local desktop_file="$BUILDROOT/usr/share/applications/$file_pattern"

    [ -f "$desktop_file" ] || return
    sed -i "s/^Categories=.*/Categories=$categories/" "$desktop_file"
}

# Apply category fixes to desktop files
fix_desktop_categories "wps-office-et.desktop" "Office;Spreadsheet;"
fix_desktop_categories "wps-office-wps.desktop" "Office;WordProcessor;"
fix_desktop_categories "wps-office-wpp.desktop" "Office;Presentation;"
fix_desktop_categories "wps-office-pdf.desktop" "Office;Viewer;"
fix_desktop_categories "wps-office-prometheus.desktop" "Office;"

# Fix double-click file opening issue
# This script configures WPS Office to handle file associations properly
# Required for compatibility with file managers and desktop environments
cat <<'EOF' | create_exec_file "$PRODUCTDIR/office6/init-wps-config.sh"
#!/bin/bash

CONFIG_DIR="$HOME/.config/Kingsoft"
CONFIG_FILE="$CONFIG_DIR/Office.conf"

# Add WPS Office configuration parameter if it doesn't exist
add_config_parameter() {
    local param_name="$1"
    
    if ! grep -q "wpsoffice\\\\Application%20Settings\\\\${param_name}=" "$CONFIG_FILE"; then
        echo "wpsoffice\\Application%20Settings\\${param_name}=prome_fushion" >> "$CONFIG_FILE"
    fi
}

if [ ! -f "$CONFIG_FILE" ]; then
    # Initialize configuration
    mkdir -p "$CONFIG_DIR"
    echo "[6.0]" > "$CONFIG_FILE"
fi

# Configure component modes for file association support
add_config_parameter "AppComponentMode"
add_config_parameter "AppComponentModeInstall"
EOF

for f in wps et wpp wpspdf; do
    bin_file="$BUILDROOT/usr/bin/$f"
    [ -f "$bin_file" ] || fatal "Missing $bin_file"
    sed -i '2i . /opt/kingsoft/wps-office/office6/init-wps-config.sh' "$bin_file"
done

add_libs_requires
