#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=rutokenplugin
PRODUCTDIR=/opt/aktivco/rutokenplugin

. $(dirname $0)/common.sh

# The package has no maintainer scripts.
# Browser registration is shipped in the package:
#   native messaging hosts in /etc/chromium (also used by Yandex Browser and Chromium-Gost),
#   /etc/opt/chrome and /usr/lib64/mozilla,
#   the Chrome Web Store extension in /opt/google/chrome/extensions.
# FireWyrmNativeMessageHost looks for libnpRutokenPlugin.so in /usr/lib/mozilla/plugins.

# Firefox looks in /usr/lib/mozilla/native-messaging-hosts too
if [ ! -e "$BUILDROOT/usr/lib/mozilla/native-messaging-hosts/ru.rutoken.firewyrmhost.json" ] ; then
    mkdir -p "$BUILDROOT/usr/lib/mozilla/native-messaging-hosts"
    ln -s $PRODUCTDIR/ru.rutoken.firewyrmhost.firefox.json "$BUILDROOT/usr/lib/mozilla/native-messaging-hosts/ru.rutoken.firewyrmhost.json"
    pack_file /usr/lib/mozilla/native-messaging-hosts/ru.rutoken.firewyrmhost.json
fi

# offer the Rutoken Plugin adapter extension in Chromium too (like Google Chrome does via /opt/google/chrome/extensions)
install_file /opt/google/chrome/extensions/ohedcglhbbfdgaogjhcclacoccbagkjg.json /usr/share/chromium/extensions/ohedcglhbbfdgaogjhcclacoccbagkjg.json

# librtpkcs11ecp.so is a private copy loaded via RPATH $ORIGIN by libnpRutokenPlugin.so:
# the plugin needs C_EX_GetFunctionListExtended, missed in older system librtpkcs11ecp.

# pcscd and CCID reader driver are needed for Rutoken
add_requires /usr/sbin/pcscd
case "$(epm print info -p)" in
    deb)
        add_requires libccid
        ;;
    *)
        # provided by pcsc-lite-ccid in ALT and Fedora, ccid in ROSA
        add_requires ccid
        ;;
esac
