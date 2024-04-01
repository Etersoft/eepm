#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

fix_chrome_sandbox

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Name=Meridius
Exec=meridius
Terminal=false
Type=Application
Icon=$PRODUCT
Comment=Music Player for vk.com based on Electron, NuxtJS, Vue.
Categories=AudioVideo;Audio;Video;Player
EOF

#install_file $PRODUCTDIR/io.github.purplehorrorrus.Meridius.desktop /usr/share/applications/$PRODUCT.desktop
install_file $PRODUCTDIR/builder/icons/linux/256x256.png /usr/share/pixmaps/$PRODUCT.png

add_bin_exec_command

# remove broken discord integration
# error: version `GLIBC_2.33' not found (required by ./python3)
remove_dir $PRODUCTDIR/resources/app.asar.unpacked/node_modules/register-scheme

add_electron_deps
