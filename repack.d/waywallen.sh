#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=waywallen

. $(dirname $0)/common.sh

install_file $PRODUCTDIR/org.waywallen.waywallen.svg /usr/share/icons/hicolor/scalable/apps/org.waywallen.waywallen.svg
fix_desktop_file "Categories=Graphics;Qt;" "Categories=Settings;DesktopSettings;Qt;"

# AppImage bundles most Qt6 libraries, but these QML runtime libraries are
# resolved from the system and are blocked by the generic Qt reqstoplist.
add_unirequires libQt6QuickDialogs2QuickImpl.so.6 libQt6QuickDialogs2.so.6 libQt6QuickParticles.so.6 libQt6QuickShapesDesignHelpers.so.6

cat <<EOF | create_file /usr/lib/systemd/user/waywallen.service
[Unit]
Description=Waywallen wallpaper daemon
Documentation=https://github.com/waywallen/waywallen
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/waywallen --no-ui --no-tray
Restart=on-failure
RestartSec=2

[Install]
WantedBy=graphical-session.target
EOF
