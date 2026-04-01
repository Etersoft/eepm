#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=portmaster2
PRODUCTDIR=/opt/portmaster2

. $(dirname $0)/common.sh

# conflicts with legacy portmaster v1
add_conflicts portmaster

# portmaster (Tauri GUI) needs webkit2gtk
add_requires 'libwebkit2gtk-4.1.so.0()(64bit)'

# create systemd service
cat <<'EOF' | create_file /lib/systemd/system/portmaster.service
[Unit]
Description=Portmaster Privacy Suite by Safing
Documentation=https://docs.safing.io
Before=nss-lookup.target network.target
After=systemd-networkd.service
Conflicts=firewalld.service

[Service]
Type=simple
Restart=on-failure
RestartSec=10
ExecStart=/opt/portmaster2/portmaster-core --data /var/lib/portmaster
PIDFile=/var/lib/portmaster/core-lock.pid

[Install]
WantedBy=multi-user.target
EOF

# create user-facing launcher
cat <<'EOF' | create_exec_file /usr/bin/portmaster
#!/bin/sh
exec /opt/portmaster2/portmaster --data /var/lib/portmaster "$@"
EOF

# install icon from original deb if available
if [ -f "$BUILDROOT/usr/share/icons/hicolor/128x128/apps/portmaster.png" ] ; then
    install_file /usr/share/icons/hicolor/128x128/apps/portmaster.png /usr/share/pixmaps/portmaster.png
fi

cat <<EOF | create_file /usr/share/applications/portmaster.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Portmaster
Comment=Privacy Suite and Application Firewall
Exec=portmaster
Icon=portmaster
Terminal=false
Categories=Network;Security;
EOF

subst "s|^Group:.*|Group: Networking/Other|" $SPEC
