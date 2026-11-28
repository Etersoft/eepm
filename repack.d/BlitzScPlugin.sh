#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=BlitzScPlugin
# npBlitzScPlugin.so has RPATH /usr/share/BlitzScPlugin, so keep the vendor location
PRODUCTDIR=/usr/share/BlitzScPlugin

. $(dirname $0)/common.sh

# The original postinstall script is replaced by the packaged files:
#   native messaging host manifests for Chromium/Chrome (also used by Yandex Browser and Chromium-Gost) and Firefox,
#   npBlitzScPlugin.so link in mozilla plugins dir (FireWyrmNativeMessageHost looks for the plugin there).

NATIVEHOST=$PRODUCTDIR/FireWyrmNativeMessageHost
NMHNAME=ru.reaxoft.firewyrmhost

for manifestdir in /etc/opt/chrome/native-messaging-hosts /etc/chromium/native-messaging-hosts ; do
    sed -e "s|_FILEPATH_|$NATIVEHOST|" "$BUILDROOT$PRODUCTDIR/$NMHNAME.json" | create_file "$manifestdir/$NMHNAME.json"
done

for manifestdir in /usr/lib/mozilla/native-messaging-hosts /usr/lib64/mozilla/native-messaging-hosts ; do
    sed -e "s|_FILEPATH_|$NATIVEHOST|" "$BUILDROOT$PRODUCTDIR/${NMHNAME}_f.json" | create_file "$manifestdir/$NMHNAME.json"
done

remove_file $PRODUCTDIR/$NMHNAME.json
remove_file $PRODUCTDIR/${NMHNAME}_f.json

mkdir -p "$BUILDROOT/usr/lib64/mozilla/plugins"
ln -s $PRODUCTDIR/npBlitzScPlugin.so "$BUILDROOT/usr/lib64/mozilla/plugins/npBlitzScPlugin.so"
pack_file /usr/lib64/mozilla/plugins/npBlitzScPlugin.so

# offer the Blitz Smart Card Plugin extension from the Chrome Web Store
for extdir in /usr/share/chromium/extensions /usr/share/google-chrome/extensions ; do
    cat <<EOF | create_file "$extdir/pomekhchngaooffdadfjnghfkaeipoba.json"
{
    "external_update_url": "https://clients2.google.com/service/update2/crx"
}
EOF
done

# use system token PKCS#11 libraries (installed by ecryptomgr install rutoken|jacarta)
# the plugin dlopens them by name: librtpkcs11ecp.so is found in the system libdir
remove_file $PRODUCTDIR/librtpkcs11ecp.so
# JaCarta library is libjcPKCS11-2.so in the system
remove_file $PRODUCTDIR/libjcPKCS11_2.so
case "$(epm print info -p)" in
    deb)
        jclib=/usr/lib/libjcPKCS11-2.so
        ;;
    *)
        jclib=/usr/lib64/libjcPKCS11-2.so
        ;;
esac
ln -s $jclib "$BUILDROOT$PRODUCTDIR/libjcPKCS11_2.so"
pack_file $PRODUCTDIR/libjcPKCS11_2.so

# drop '.' (current directory) from RPATH
epm assure patchelf || fatal
for i in npBlitzScPlugin.so libblitzpkcs11.so libcapi2pkcs11.so ; do
    a='' patchelf --force-rpath --set-rpath $PRODUCTDIR "$BUILDROOT$PRODUCTDIR/$i" || fatal
done

# libcapi2pkcs11.so is a bridge to CryptoPro CSP (libcapi10.so.4 from /opt/cprocsp), loaded only if CryptoPro is installed
ignore_lib_requires libcapi10.so.4

# pcscd and CCID reader driver are needed for smart cards and tokens (see ecryptomgr install pcsc)
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
