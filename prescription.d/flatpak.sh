#!/bin/sh

[ "$1" != "--run" ] && echo "Add flatpak support to system" && exit

. $(dirname $0)/common.sh

assure_root

[ "$(epm print info -s)" = "alt" ] || fatal "Only ALTLinux is supported"

# Мсправляет ошибку "enabling unprivileged user namespaces" без перезагрузки
a= sysctl -w kernel.unprivileged_userns_clone=1

epm install --skip-installed flatpak flatpak-repo-flathub sysctl-conf-userns

if epm installed plasma5-discover ; then
    epm install --skip-installed plasma5-discover-flatpak
fi

if epm installed plasma5-kwin ; then
    epm install --skip-installed plasma5-xdg-desktop-portal-kde xdg-desktop-portal
elif epm installed deepin-kwin2 ; then
    epm install --skip-installed xdg-desktop-portal-dde xdg-desktop-portal
elif epm installed gnome-shell ; then
    epm install --skip-installed xdg-desktop-portal-gnome xdg-desktop-portal
elif epm installed xfwm4 ; then
    epm install --skip-installed xdg-desktop-portal-gtk xdg-desktop-portal
elif epm installed mate-window-manager ; then
    epm install --skip-installed xdg-desktop-portal-gtk xdg-desktop-portal
elif epm installed sway ; then
    epm install --skip-installed xdg-desktop-portal-wlr xdg-desktop-portal
elif epm installed hyprland ; then
    epm install --skip-installed xdg-desktop-portal-hyprland xdg-desktop-portal
elif epm installed muffin ; then
    epm install --skip-installed xdg-desktop-portal-xapp xdg-desktop-portal
elif epm installed liblxqt ; then
    epm install --skip-installed xdg-desktop-portal-lxqt xdg-desktop-portal
elif epm installed lxde-common ; then
    epm install --skip-installed xdg-desktop-portal-gtk xdg-desktop-portal
fi

echo "Flatpak successfully installed, but you need to reboot for xdg-desktop-portals to work"
