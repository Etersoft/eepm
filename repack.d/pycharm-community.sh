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

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm Community Edition
Comment=Python IDE for Professional Developers
Exec=pycharm %f
Icon=pycharm
Terminal=false
StartupNotify=true
StartupWMClass=jetbrains-pycharm-ce
Categories=Development;IDE;Python;
EOF

install_file $PRODUCTDIR/bin/$PRODUCT.png /usr/share/pixmaps/
install_file $PRODUCTDIR/bin/$PRODUCT.svg /usr/share/pixmaps/

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

cd $BUILDROOT/ || exit

for i in $PRODUCTDIR/plugins/python-ce/helpers/pydev/_pydevd_bundle/pydevd_cython_{darwin,win32}* ; do
    remove_file $i
done

for i in $PRODUCTDIR/plugins/python-ce/helpers/pydev/_pydevd_frame_eval/*-{win32.pyd,win_amd64.pyd,darwin.so} ; do
    remove_file $i
done

subst 's|%dir "'$PRODUCTDIR'/"||' $SPEC
subst 's|%dir "'$PRODUCTDIR'/bin/"||' $SPEC
subst 's|%dir "'$PRODUCTDIR'/lib/"||' $SPEC
subst 's|%dir "'$PRODUCTDIR'/plugins/"||' $SPEC

pack_dir $PRODUCTDIR/
pack_dir $PRODUCTDIR/bin/
pack_dir $PRODUCTDIR/lib/
pack_dir $PRODUCTDIR/plugins/

add_libs_requires
