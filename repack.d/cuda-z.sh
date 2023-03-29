#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=cuda-z

. $(dirname $0)/common.sh

subst "s|^Group:.*|Group: Graphics|" $SPEC
subst "s|^License: unknown$|License: GPLv2|" $SPEC
subst "s|^URL:.*|URL: http://cuda-z.sourceforge.net/|" $SPEC
subst "s|^Summary:.*|Summary: CUDA-Z|" $SPEC

add_bin_link_command

# create desktop file
mkdir -p $BUILDROOT/usr/share/applications/
cat <<EOF >$BUILDROOT/usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Name=CUDA-Z
Comment=CUDA Information Utility
Type=Application
Icon=$PRODUCT
Exec=$PRODUCT
Terminal=false
EOF
pack_file /usr/share/applications/$PRODUCT.desktop

install_file "https://cuda-z.sourceforge.net/img/web-download-detect.png" /usr/share/pixmaps/$PRODUCT.png

# Running 32 bit cuda-z on Ubuntu
# libc6:i386 libstdc++6:i386 zlib1g:i386 libx11-6:i386 libxext6:i386 libxrender1:i386
# http://blog.redscorp.net/?p=94

# static linked
# strace -f cuda-z 2>&1 | grep \.so | grep lib64/lib | grep fstat | sed -e 's|.*<||' -e 's|>.*||' | sort -u | epm --quiet --short qf | sort -u | xargs -n100
# glibc-core glibc-pthread libgcc1 libstdc++6 libX11 libXau libxcb libXcursor libXdmcp libXext libXfixes libXrender
if [ "$(epm print info -s)" = "alt" ] ; then
    add_requires glibc-core glibc-pthread libgcc1 libstdc++6 libX11 libXau libxcb libXcursor libXdmcp libXext libXfixes libXrender
fi
