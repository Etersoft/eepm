#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCTDIR=/opt/kingsoft/wps-office

. $(dirname $0)/common.sh

#REQUIRES="fonts-ttf-liberation, fonts-ttf-dejavu"
#subst "s|^\(Name: .*\)$|# Converted from original package requires\nRequires:$REQUIRES\n\1|g" $SPEC

# Clean up unnecessary directories
remove_dir /etc/cron.d
remove_dir /etc/logrotate.d
remove_dir /etc/xdg

# Fix ALT bug 43751
remove_file /usr/share/desktop-directories/wps-office.directory

# Fix ALT bug 45683
remove_file "$PRODUCTDIR/office6/wpscloudsvr"

# Remove problematic library (libkappessframework.so()(64bit))
remove_file "$PRODUCTDIR/office6/addons/pdfbatchcompression/libpdfbatchcompressionapp.so"

# Use system libjpeg
# https://github.com/NixOS/nixpkgs/commit/da74ad3a905aa45ee6e4f8b4b69b56930195adcb
remove_file "$PRODUCTDIR/office6/libjpeg.so*"

# Fix theme system on WPS Office 11
is_stdcpp_enough "12.1" && remove_file "$PRODUCTDIR/office6/libstdc++.so*"

# Ignore specific library requirements
ignore_lib_requires "libc++.so"
ignore_lib_requires "libuof.so"

# Remove Qt 4 dependencies
remove_file "$PRODUCTDIR/office6/librpcwpsapi.so"
remove_file "$PRODUCTDIR/office6/librpcwppapi.so"
remove_file "$PRODUCTDIR/office6/librpcetapi.so"

# Fix Python 2 to Python 3 command
# https://aur.archlinux.org/cgit/aur.git/tree/fix-wps-python-parse.patch?h=wps-office-cn
subst 's/python -c '\''import sys, urllib; print urllib.unquote(sys.argv\[1\])'\''/python3 -c '\''import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))'\''/' \
	"$BUILDROOT/usr/bin/wps"

# Remove problematic image file
remove_file "$PRODUCTDIR/office6/mui/zh_CN/resource/help/etrainbow/images/Ribbon/custom_%20sequence.gif"

# Fixes the problem of incorrect text display in WPS Office in non-GTK environments (KDE, Lxde, etc.)
cat <<EOF >"$BUILDROOT/opt/kingsoft/wps-office/office6/setenv.sh"
#!/bin/bash

if ! echo "\${XDG_CURRENT_DESKTOP:-}" | grep -qiE '(gnome|xfce|unity|mate|cinnamon|budgie)' &&
   ! ps -e | grep -qiE '(gnome-shell|xfce4-session|unity-panel|mate-panel|cinnamon|budgie-panel)'
then
    export XDG_CURRENT_DESKTOP=GNOME
fi
EOF

chmod 755 "$BUILDROOT/opt/kingsoft/wps-office/office6/setenv.sh"

for bin_file in \
	"$BUILDROOT/usr/bin/wps" \
	"$BUILDROOT/usr/bin/et" \
	"$BUILDROOT/usr/bin/wpp" \
	"$BUILDROOT/usr/bin/wpspdf"; do
	[ -f "$bin_file" ] || continue
	grep -q 'setenv.sh' "$bin_file" || sed -i '2i . /opt/kingsoft/wps-office/office6/setenv.sh' "$bin_file"
done

subst "s|%files|%files\n/opt/kingsoft/wps-office/office6/setenv.sh|" "$SPEC"

add_libs_requires
