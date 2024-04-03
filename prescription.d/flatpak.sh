#!/bin/sh

[ "$1" != "--run" ] && echo "Add flatpak support to system" && exit

. $(dirname $0)/common.sh

assure_root

[ "$(epm print info -s)" = "alt" ] || fatal "Only ALTLinux is supported"

# Мсправляет ошибку "enabling unprivileged user namespaces" без перезагрузки
a= sysctl -w kernel.unprivileged_userns_clone=1

epm install flatpak flatpak-repo-flathub sysctl-conf-userns

if epm installed plasma5-discover ; then
    epm install plasma5-discover-flatpak
fi

echo "Flatpak successfully installed, but epm play is the preferred way to install the software."
