#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCTDIR=/opt/vdhcoapp

. $(dirname $0)/common.sh

add_conflicts net.downloadhelper.coapp

add_unirequires /usr/bin/xdg-open
add_unirequires /usr/bin/ffmpeg /usr/bin/ffplay /usr/bin/ffprobe

# use xdg-open from the system
rm -v .$PRODUCTDIR/xdg-open
ln -s /usr/bin/xdg-open .$PRODUCTDIR/xdg-open

cat <<EOF | create_file /usr/lib64/mozilla/native-messaging-hosts/net.downloadhelper.coapp.json
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

cat <<EOF | create_file /etc/chromium/native-messaging-hosts/net.downloadhelper.coapp.json
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
