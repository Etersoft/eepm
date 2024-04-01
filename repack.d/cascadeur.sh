#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

move_to_opt /cascadeur-linux

subst "s|^License: unknown$|License: Proprietary|" $SPEC
subst "s|^Summary:.*|Summary: Cascadeur - a physics‑based 3D animation software|" $SPEC


add_bin_exec_command

# from https://www.producthunt.com/posts/cascadeur
# QmQLQK6byKKzvvHEA84h4Auxci1o9T6bCQQikZFgRM8KBx
install_file "https://ph-files.imgix.net/e07b5249-d804-4b4e-9458-fa037d30a14b.png?auto=compress&codec=mozjpeg&cs=strip&auto=format&w=72&h=72&fit=crop&bg=0fff&dpr=1" /usr/share/pixmaps/$PRODUCT.png

cat <<EOF |create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Cascadeur
Comment=Cascadeur - a physics‑based 3D animation software
Icon=$PRODUCT
Exec=$PRODUCT %u
Categories=Games;
Terminal=false
EOF

add_requires qt5-imageformats

add_libs_requires
