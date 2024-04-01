#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=liteide

. $(dirname $0)/common.sh

# previous package name
add_conflicts liteidex

subst "s|^Group:.*|Group: Development/Tools|" $SPEC
subst "s|^License: unknown$|License: LGPLv2|" $SPEC
subst "s|^URL:.*|URL: https://liteide.org/en/|" $SPEC
subst "s|^Summary:.*|Summary: LiteIDE is a simple, open source, cross-platform Go IDE|" $SPEC

move_to_opt /liteide

for i in gocode gomodifytags gotools liteide ; do
    add_bin_link_command $i $PRODUCTDIR/bin/$i
done

install_file $PRODUCTDIR/share/liteide/welcome/images/liteide.png /usr/share/pixmaps/$PRODUCT.png

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Type=Application
Name=LiteIDE
Exec=$PRODUCT
Icon=$PRODUCT
Comment=LiteIDE is a simple, open source, cross-platform Go IDE
Terminal=false
Categories=Development;
EOF

# https://bugzilla.altlinux.org/45635
add_requires golang

set_autoreq 'yes'
