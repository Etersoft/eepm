#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=cuda-z

. $(dirname $0)/common.sh

# static linked
# strace -f cuda-z 2>&1 | grep \.so | grep lib64/lib | grep fstat | sed -e 's|.*<||' -e 's|>.*||' | sort -u | epm --quiet --short qf | sort -u | xargs -n100
# glibc-core glibc-pthread libgcc1 libstdc++6 libX11 libXau libxcb libXcursor libXdmcp libXext libXfixes libXrender

add_unirequires libstdc++.so.6 libX11-xcb.so.1 libX11.so.6 libXau.so.6 libxcb.so.1 libXcursor.so.1 libXdmcp.so.6 libXext.so.6 libXfixes.so.3 libXrender.so.1

add_bin_link_command

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Name=CUDA-Z
Comment=CUDA Information Utility
Type=Application
Icon=$PRODUCT
Exec=$PRODUCT
Terminal=false
EOF

install_file "https://cuda-z.sourceforge.net/img/web-download-detect.png" /usr/share/pixmaps/$PRODUCT.png

# Running 32 bit cuda-z on Ubuntu
# libc6:i386 libstdc++6:i386 zlib1g:i386 libx11-6:i386 libxext6:i386 libxrender1:i386
# https://blog.redscorp.net/?p=94

add_libs_requires
