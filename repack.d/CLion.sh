#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=clion
PRODUCTCUR=CLion

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Development/Tools|" $SPEC
#subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: https://www.jetbrains.com/clion/|" $SPEC
subst "s|^Summary:.*|Summary: CLion - A cross-platform IDE for C and C++|" $SPEC

move_to_opt "/$PRODUCT-*"
add_bin_link_command $PRODUCT $PRODUCTDIR/bin/$PRODUCT.sh
add_bin_link_command $PRODUCTCUR $PRODUCT

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=CLion
Comment=A cross-platform IDE for C and C++
Exec=$PRODUCT %f
Icon=$PRODUCT
Terminal=false
StartupNotify=true
StartupWMClass=jetbrains-clion
Categories=Development;IDE
EOF

install_file $PRODUCTDIR/bin/$PRODUCT.png /usr/share/pixmaps/$PRODUCT.png
install_file $PRODUCTDIR/bin/$PRODUCT.svg /usr/share/pixmaps/$PRODUCT.svg

# The bundled Radler/.NET stack ships musl runtimes for non-target Linux
# variants. They are not needed on our glibc targets and introduce impossible
# cross-arch soname dependencies.
for d in "$BUILDROOT"$PRODUCTDIR/plugins/clion-radler/DotFiles/runtimes/linux-musl-* ; do
    [ -d "$d" ] || continue
    remove_dir "${d#"$BUILDROOT"}"
done

# Keep optional debugger/remote-dev pieces installed even when they pull
# legacy or distro-specific sonames. This preserves more JetBrains features at
# runtime for users who have compatible libs or install them manually.
ignore_lib_requires liblttng-ust.so.0
ignore_lib_requires libcrypto.so.1.1 libssl.so.1.1 libnsl.so.1

# Debian's dh_strip_nondeterminism rewrites JetBrains bundled archives during
# alien conversion and makes CLion repacking impractically slow.
skip_deb_dh_strip_nondeterminism

# kind of hack
subst 's|%dir "'$PRODUCTDIR'/"||' $SPEC
subst 's|%dir "'$PRODUCTDIR'/bin/"||' $SPEC
subst 's|%dir "'$PRODUCTDIR'/lib/"||' $SPEC
subst 's|%dir "'$PRODUCTDIR'/plugins/"||' $SPEC

pack_dir $PRODUCTDIR/
pack_dir $PRODUCTDIR/bin/
pack_dir $PRODUCTDIR/lib/
pack_dir $PRODUCTDIR/plugins/
