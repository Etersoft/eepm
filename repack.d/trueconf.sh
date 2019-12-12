#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

subst 's|%dir "/usr/share/icons/hicolor/.*||' $SPEC

# Make relative symlink
# TODO: alien does not support ghost files?
mkdir -p $BUILDROOT/usr/bin/
rm -f $BUILDROOT/usr/bin/trueconf
ln -s ../../opt/trueconf/trueconf-client $BUILDROOT/usr/bin/trueconf
chmod a+x $BUILDROOT/opt/trueconf/trueconf-client

rm -rvf $BUILDROOT/usr/local/

[ "$($DISTRVENDOR -b)" = 64 ] && LIBUDEV=/lib64/libudev.so.0 || LIBUDEV=/lib/libudev.so.0
ln -s $LIBUDEV $BUILDROOT/opt/trueconf/lib/libudev.so.0

REQUIRES="libudev1 pulseaudio alsa-utils libv4l sqlite gtk2 libpng openssl udev libxslt xdg-utils"
subst "s|^\(Name: .*\)$|# FIXME: due libcrypto.so.10(libcrypto.so.10)(64bit) autoreqs\nAutoReq:yes,nolib\n# Converted from original package requires\nRequires:$REQUIRES\n\1|g" $SPEC

subst 's|.*/usr/local.*||' $SPEC

