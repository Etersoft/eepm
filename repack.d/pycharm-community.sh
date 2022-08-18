#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=pycharm
PRODUCTCUR=pycharm-community
PRODUCTDIR=/opt/$PRODUCTCUR

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Development/Python|" $SPEC
#subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: https://www.jetbrains.com/pycharm|" $SPEC
subst "s|^Summary:.*|Summary: The Python IDE for Professional Developers|" $SPEC

move_to_opt "/pycharm-community-*"
add_bin_link_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT.sh

# TODO:
# https://github.com/archlinux/svntogit-community/blob/packages/pycharm-community-edition/trunk/pycharm.sh

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm Community Edition
Comment=Python IDE for Professional Developers
Exec=/usr/bin/pycharm %f
Icon=pycharm
Terminal=false
StartupNotify=true
StartupWMClass=jetbrains-pycharm-ce
Categories=Development;IDE;Python;
EOF

pack_file /usr/share/applications/$PRODUCT.desktop

mkdir -p $BUILDROOT/usr/share/pixmaps/
cp -a $BUILDROOT$PRODUCTDIR/bin/$PRODUCT.png $BUILDROOT/usr/share/pixmaps/
cp -a $BUILDROOT$PRODUCTDIR/bin/$PRODUCT.svg $BUILDROOT/usr/share/pixmaps/
pack_file /usr/share/pixmaps/$PRODUCT.png
pack_file /usr/share/pixmaps/$PRODUCT.svg

# TODO: support other arch
for i in arm aarch64 mips64el ppc64le x86 x86-64 ; do
    [ "$i" = "x86-64" ] && continue
    remove_dir $PRODUCTDIR/lib/pty4j-native/linux/$i/
done

# TODO: support other platforms
for i in darwin-aarch64 darwin-x86-64 linux-aarch64 linux-x86-64 win32-x86-64 ; do
    [ "$i" = "linux-x86-64" ] && continue
    remove_dir $PRODUCTDIR/plugins/cwm-plugin/quiche-native/$i/
done

for i in attach_amd64.dll attach_linux_x86.so attach_linux_amd64.so attach_x86.dll attach_x86.dylib attach_x86_64.dylib ; do
    [ "$i" = "attach_linux_amd64.so" ] && continue
    remove_dir $PRODUCTDIR/plugins/python-ce/helpers/pydev/pydevd_attach_to_process/
done

for i in $BUILDROOT$PRODUCTDIR/plugins/python-ce/helpers/pydev/_pydevd_bundle/pydevd_cython_{darwin,win32}* ; do
    remove_file $PRODUCTDIR/plugins/python-ce/helpers/pydev/_pydevd_bundle/$(basename $i)
done

for i in $BUILDROOT$PRODUCTDIR/plugins/python-ce/helpers/pydev/_pydevd_frame_eval/{win32.pyd,win_amd64.pyd,darwin.so} ; do
    remove_file $PRODUCTDIR/plugins/python-ce/helpers/pydev/_pydevd_frame_eval/$(basename $i)
done

subst 's|%dir "'$PRODUCTDIR'/"||' $SPEC
subst 's|%dir "'$PRODUCTDIR'/bin/"||' $SPEC
subst 's|%dir "'$PRODUCTDIR'/lib/"||' $SPEC
subst 's|%dir "'$PRODUCTDIR'/plugins/"||' $SPEC

pack_dir $PRODUCTDIR/
pack_dir $PRODUCTDIR/bin/
pack_dir $PRODUCTDIR/lib/
pack_dir $PRODUCTDIR/plugins/

subst '1iAutoProv:no' $SPEC
subst '1iAutoReq:yes,nopython,nopython3' $SPEC
