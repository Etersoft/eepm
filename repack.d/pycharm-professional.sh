#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=pycharm-pro
PRODUCTCUR=pycharm
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Development/Python|" $SPEC
#subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: https://www.jetbrains.com/pycharm|" $SPEC
subst "s|^Summary:.*|Summary: The Python IDE for Professional Developers (Free 30-day trial available)|" $SPEC

move_to_opt "/pycharm-*"
add_bin_link_command $PRODUCT $PRODUCTDIR/bin/$PRODUCTCUR.sh

cat <<EOF |create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm Professional Edition
Comment=Python IDE for Professional Developers (Free 30-day trial available)
Exec=$PRODUCT %f
Icon=$PRODUCT
Terminal=false
StartupNotify=true
StartupWMClass=jetbrains-pycharm-pro
Categories=Development;IDE;Python;
EOF

install_file $PRODUCTDIR/bin/$PRODUCTCUR.png /usr/share/pixmaps/$PRODUCT.png
install_file $PRODUCTDIR/bin/$PRODUCTCUR.svg /usr/share/pixmaps/$PRODUCT.svg

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

for i in attach_amd64.dll attach_x86.dll attach_x86.dylib attach_x86_64.dylib ; do
    remove_dir $PRODUCTDIR/plugins/python/helpers/pydev/pydevd_attach_to_process/
done

cd $BUILDROOT/ || exit

for i in $PRODUCTDIR/plugins/python/helpers/pydev/_pydevd_bundle/pydevd_cython_{darwin,win32}* ; do
    remove_file $i
done

for i in $PRODUCTDIR/plugins/python/helpers/pydev/_pydevd_frame_eval/*-{win32.pyd,win_amd64.pyd,darwin.so} ; do
    remove_file $i
done

remove_file $PRODUCTDIR/plugins/performanceTesting/bin/libyjpagent.so
filter_from_requires '\\/lib\\/libc.so.6(GLIBC'
filter_from_requires '\\/lib\\/libgcc_s.so.1(GCC_'
filter_from_requires '\\/usr\\/lib\\/libstdc++.so.6('
filter_from_requires 'libcrypto.so.10(libcrypto.so.10)(64bit)'
filter_from_requires '\\/lib\\/ld-linux-aarch64.so.1'

cd $BUILDROOT$PRODUCTDIR/ || exit

# FIXME: improve * support in remove_file
file=$(basename $(ls $BUILDROOT$PRODUCTDIR/plugins/tailwindcss/server/node.napi.musl-*.node))
[ -n "$file" ] && remove_file $PRODUCTDIR/plugins/tailwindcss/server/$file

subst 's|%dir "'$PRODUCTDIR'/"||' $SPEC
subst 's|%dir "'$PRODUCTDIR'/bin/"||' $SPEC
subst 's|%dir "'$PRODUCTDIR'/lib/"||' $SPEC
subst 's|%dir "'$PRODUCTDIR'/plugins/"||' $SPEC

pack_dir $PRODUCTDIR/
pack_dir $PRODUCTDIR/bin/
pack_dir $PRODUCTDIR/lib/
pack_dir $PRODUCTDIR/plugins/

add_libs_requires
