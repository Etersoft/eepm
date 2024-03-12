#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=icaclient

# Fix macro in file list
subst 's|%_h32bit|%%_h32bit|g' $SPEC

ignore_lib_requires libunwind.so.1 libgssapi.so.3
ignore_lib_requires libgstreamer-0.10.so.0 libgstapp-0.10.so.0 libgstbase-0.10.so.0 libgstinterfaces-0.10.so.0 libgstpbutils-0.10.so.0
ignore_lib_requires libgstpbutils-1.0.so.0 libgstreamer-1.0.so.0 libgstvideo-1.0.so.0 libgssapi_krb5.so.2 libgstapp-1.0.so.0 libgstbase-1.0.so.0
ignore_lib_requires libc++.so.1 libc++abi.so.1

# glibc >= 2.7 gtk2 >= 2.12 gtk3 libICE >= 1.0.6 libSM >= 1.2.1 libX11 >= 1.6.0 libXext >= 1.3.2 libXinerama libXmu >= 1.1.1 libXpm >= 3.5.10 libXrender libXt >= 1.1.4 libpng speexdsp sqlite-libs webkit2gtk3 >= 2.26
# libc6 (>= 2.13-38), libice6 (>= 1:1.0.0), libgtk2.0-0 (>= 2.12.0), libsm6, libx11-6, libxext6, libxmu6, libxpm4, libasound2, libstdc++6, libidn11 | libidn12, zlib1g, curl (>= 7.68), libsqlite3-0, libspeexdsp1
# 
add_libs_requires

exit 0

# Remove unmets
subst '1i%filter_from_requires /\\(SUNWut\\|LIBJPEG_6.2\\|kdelibs\\|killproc\\|start_daemon\\)/d' $SPEC
subst '1i%filter_from_requires /^libc.so.6(GLIBC_PRIVATE).*/d' $SPEC


# Add requires of lsb-init for init script
subst '/Group/Requires: lsb-init' $SPEC

set_autoreq 'yes'
