#!/bin/sh

[ "$1" != "--run" ] && echo "Add flatpak support to system" && exit

. $(dirname $0)/common.sh

assure_root

[ "$(epm print info -s)" = "alt" ] || fatal "Only ALTLinux is supported"

# Исправляет ошибку "enabling unprivileged user namespaces" без перезагрузки
a= sysctl -w kernel.unprivileged_userns_clone=1

install_portals=""

while read -r window_manager package ; do
    if epm installed $window_manager </dev/null ; then
        install_portals+=" $package"
    fi
done <<EOF
    plasma5-kwin        plasma5-xdg-desktop-portal-kde
    deepin-kwin2        xdg-desktop-portal-dde
    gnome-shell         xdg-desktop-portal-gnome
    xfwm4               xdg-desktop-portal-gtk
    mate-window-manager xdg-desktop-portal-gtk
    sway                xdg-desktop-portal-wlr
    hyprland            xdg-desktop-portal-hyprland
    muffin              xdg-desktop-portal-xapp
    liblxqt             xdg-desktop-portal-lxqt
    lxde-common         xdg-desktop-portal-gtk
EOF

epm install --skip-installed $install_portals xdg-desktop-portal

epm install --skip-installed flatpak flatpak-repo-flathub sysctl-conf-userns

if epm installed plasma5-discover ; then
    epm install --skip-installed plasma5-discover-flatpak
fi

# Без перезагрузки dbus, порталы не заработают
serv dbus reload

# https://bugzilla.altlinux.org/46690
cat <<EOL > /etc/systemd/system/check-bwrap.service
[Unit]
Description=Check and fix permissions for bwrap
Wants=check-bwrap.path

[Service]
Type=oneshot
ExecStart=/bin/bash -c "CURRENT_PERMISSIONS=\$(stat -c '%a' /usr/bin/bwrap); if [ '\$CURRENT_PERMISSIONS' != '775' ]; then chmod 0755 /usr/bin/bwrap; fi"
EOL

cat <<EOL > /etc/systemd/system/check-bwrap.path
[Unit]
Description=Watch /usr/bin/bwrap for changes

[Path]
PathModified=/usr/bin/bwrap

[Install]
WantedBy=multi-user.target
EOL

serv on check-bwrap.path
serv start check-bwrap.service

echo "You need to log out of the session for flatpak to work."
