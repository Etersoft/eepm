#!/bin/sh -x

# Repack saby.rpm: maintainer scripts replaced by:
#   - move temp_saby/* into target dir (postinstall did `cp -r temp_saby/. .`)
#   - drop the temp_saby stub-files mechanism (used to suppress rpm warnings)
#   - create desktop and autostart entries

BUILDROOT="$1"
SPEC="$2"

PRODUCT=saby
PRODUCTCUR=Saby
PRODUCTBASEDIR=/opt/Tensor
PRODUCTDIR=/opt/Tensor/Saby

. $(dirname $0)/common.sh

# Move all from temp_saby/ to PRODUCTDIR/ — replaces postinstall `cp -r temp_saby/. PRODUCTDIR/`.
move_dir "$PRODUCTDIR/temp_saby" "$PRODUCTDIR"

# move_dir's subst can leave duplicate %dir lines (both the old PRODUCTDIR
# entry and the rewritten temp_saby one). Drop dups (normalize quotes/slashes).
awk '/^%dir/ {key=$0; gsub(/"/,"",key); gsub(/\/+$/,"",key); if (seen[key]++) next} {print}' "$SPEC" > "$SPEC.dedup" && mv "$SPEC.dedup" "$SPEC"

# Desktop entry — points to the launcher binary at PRODUCTDIR/saby
cat <<EOF | create_file /usr/share/applications/Saby.desktop
[Desktop Entry]
Name=Saby
Comment=Saby
Exec=$PRODUCTDIR/saby %U
Path=$PRODUCTDIR
Icon=$PRODUCTDIR/icons/default_dark.png
Terminal=false
Type=Application
Encoding=UTF-8
Categories=Network;
StartupNotify=true
EOF
chmod +x "$BUILDROOT/usr/share/applications/Saby.desktop"

# Autostart entry — system-wide /etc/xdg/autostart/, fires for every user on login
cat <<EOF | create_file /etc/xdg/autostart/ru.tensor.Saby.desktop
[Desktop Entry]
Name=Saby
Comment=Saby
Exec=$PRODUCTDIR/saby %U --autostart
Path=$PRODUCTDIR
Icon=$PRODUCTDIR/icons/default_dark.png
Terminal=false
Type=Application
Encoding=UTF-8
Categories=Network;
StartupNotify=true
EOF
chmod +x "$BUILDROOT/etc/xdg/autostart/ru.tensor.Saby.desktop"

# /usr/bin/saby launcher symlink
add_bin_link_command saby "$PRODUCTDIR/saby"
