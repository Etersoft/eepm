#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=space-client
PRODUCTDIR=/opt/thin-client

. $(dirname $0)/common.sh

# the original %post creates the link /usr/bin/start_vdi_client.sh
add_bin_link_command $PRODUCT $PRODUCTDIR/start_vdi_client.sh
add_bin_link_command start_vdi_client.sh $PRODUCTDIR/start_vdi_client.sh

# the original %post creates space_usbip group (used in /etc/sudoers.d/space_usbip)
cat <<EOF | create_file /usr/lib/sysusers.d/$PRODUCT.conf
g space_usbip -
EOF

# the original %post sets these permissions
chmod 0440 $BUILDROOT/etc/sudoers.d/space_usbip

# precompiled zeromq addons for other platforms
remove_dir $PRODUCTDIR/electron-client-linux-x64/resources/app.asar.unpacked/node_modules/zeromq/build/darwin
remove_dir $PRODUCTDIR/electron-client-linux-x64/resources/app.asar.unpacked/node_modules/zeromq/build/win32
remove_dir $PRODUCTDIR/electron-client-linux-x64/resources/app.asar.unpacked/node_modules/zeromq/build/linux/x64/node/musl-127-Release

# libunclip_QT uses system Qt 6
add_unirequires libQt6Core.so.6 libQt6Gui.so.6 libQt6Widgets.so.6

epm assure patchelf

# libspace-winpr2.so.2 is linked with RED OS 8 ICU (libicuuc.so.71), ALT has no such ICU:
# install it via epm play libicu<major> (a fixed URL, so it works with --ipfs too)
ICU_MAJOR="$(a='' patchelf --print-needed "$BUILDROOT$PRODUCTDIR/libs/libspace-winpr2.so.2" | sed -n 's|^libicuuc\.so\.\([0-9][0-9]*\)$|\1|p')"
if [ -n "$ICU_MAJOR" ] && [ ! -e /usr/lib64/libicuuc.so.$ICU_MAJOR ] && [ ! -e /usr/lib/libicuuc.so.$ICU_MAJOR ] ; then
    epm play libicu$ICU_MAJOR || fatal "Can't install libicu$ICU_MAJOR (needed for libicuuc.so.$ICU_MAJOR)"
fi

if [ "$(epm print info -s)" = "alt" ] ; then
    # libsentry.so uses CURL_OPENSSL_4 versioned symbols, ALT provides them in libcurl-openssl.so.4
    a='' patchelf --replace-needed libcurl.so.4 libcurl-openssl.so.4 $BUILDROOT$PRODUCTDIR/libs/libsentry.so || fatal
fi

add_electron_deps
