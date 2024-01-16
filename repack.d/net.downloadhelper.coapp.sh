#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PREINSTALL_PACKAGES="ffmpeg ffplay ffprobe xdg-utils"

. $(dirname $0)/common.sh

set_autoreq "yes"

if [ ! -f ./opt/net.downloadhelper.coapp/bin/xdg-open ] ; then
    PRODUCTDIR=/opt/vdhcoapp
    # use ffmpeg from the system
    for i in ffplay ffmpeg ffprobe ; do
        ln -sf /usr/bin/$i ./$PRODUCTDIR/$i
        pack_file $PRODUCTDIR/$i
    done

    # use xdg-open from the system
    rm -v .$PRODUCTDIR/xdg-open
    ln -s /usr/bin/xdg-open .$PRODUCTDIR/xdg-open

cat <<EOF > net.downloadhelper.coapp.json
{
  "type": "stdio",
  "allowed_extensions": [
    "weh-native-test@downloadhelper.net",
    "{b9db16a4-6edc-47ec-a1f4-b86292ed211d}"
  ],
  "name": "net.downloadhelper.coapp",
  "description": "Video DownloadHelper companion app",
  "path": "$PRODUCTDIR/vdhcoapp"
}
EOF
install_file net.downloadhelper.coapp.json /usr/lib64/mozilla/native-messaging-hosts/net.downloadhelper.coapp.json

cat <<EOF > net.downloadhelper.coapp.json
{
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://lmjnegcaeklhafolokijcfjliaokphfk/",
    "chrome-extension://pfoiagbblcbmognbkekfpodpidedkmcc/",
    "chrome-extension://jmkaglaafmhbcpleggkmaliipiilhldn/",
    "chrome-extension://fojefjolbhfidomcaelhceoldmmpcaga/"
  ],
  "name": "net.downloadhelper.coapp",
  "description": "Video DownloadHelper companion app",
  "path": "$PRODUCTDIR/vdhcoapp"
}
EOF
install_file net.downloadhelper.coapp.json /etc/chromium/native-messaging-hosts/net.downloadhelper.coapp.json

    exit
fi

# fix libdir
install_file /usr/lib/mozilla/native-messaging-hosts/net.downloadhelper.coapp.json /usr/lib64/mozilla/native-messaging-hosts/net.downloadhelper.coapp.json
remove_dir /usr/lib

# use ffmpeg from the system
remove_dir /opt/net.downloadhelper.coapp/converter/build/linux/64
mkdir -p opt/net.downloadhelper.coapp/converter/build/linux/64
pack_dir /opt/net.downloadhelper.coapp/converter/build/linux/64
for i in ffplay ffmpeg ffprobe ; do
    ln -s /usr/bin/$i ./opt/net.downloadhelper.coapp/converter/build/linux/64/$i
    pack_file /opt/net.downloadhelper.coapp/converter/build/linux/64/$i
done

# use xdg-open from the system
rm -v ./opt/net.downloadhelper.coapp/bin/xdg-open
ln -s /usr/bin/xdg-open ./opt/net.downloadhelper.coapp/bin/xdg-open
