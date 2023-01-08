#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT="$(grep "^Name: " $SPEC | sed -e "s|Name: ||g" | head -n1)"
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

# move package to /opt
ROOTDIR=$(basename $(find $BUILDROOT -mindepth 1 -maxdepth 1 -type d))
mkdir -p $BUILDROOT/opt
mv $BUILDROOT/$ROOTDIR $BUILDROOT$PRODUCTDIR
subst "s|\"/$ROOTDIR/|\"$PRODUCTDIR/|" $SPEC

fix_chrome_sandbox

cd $BUILDROOT$PRODUCTDIR

mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF > $BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Name=Meridius
Exec=meridius
Terminal=false
Type=Application
Icon=$PRODUCT
Comment=Music Player for vk.com based on Electron, NuxtJS, Vue.
Categories=AudioVideo;Audio;Video;Player
EOF
pack_file /usr/share/applications/$DESKTOPFILE

mkdir -p $BUILDROOT/usr/share/pixmaps/
cp builder/icons/linux/256x256.png $BUILDROOT/usr/share/pixmaps/
pack_file /usr/share/pixmaps/$ICONFILE

cd - >/dev/null

add_bin_exec_command $PRODUCT

# remove broken discord integration
# error: version `GLIBC_2.33' not found (required by ./python3)
remove_dir $PRODUCTDIR/resources/app.asar.unpacked/node_modules/register-scheme

subst '1iAutoProv:no' $SPEC

# ignore embedded libs
drop_embedded_reqs
