#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common-chromium-browser.sh

move_to_opt "/podman-desktop*"

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Type=Application
Name=Podman Desktop
Exec=$PRODUCT
Icon=$PRODUCT
Terminal=false
StartupWMClass=Podman Desktop
Categories=Utility;
EOF

install_file https://raw.githubusercontent.com/podman-desktop/podman-desktop/refs/heads/main/buildResources/icon.svg /usr/share/icons/hicolor/scalable/apps/$PRODUCT.svg

add_bin_link_command

add_electron_deps

add_libs_requires
add_requires '/usr/bin/podman'
