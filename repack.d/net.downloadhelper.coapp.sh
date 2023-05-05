#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"

PREINSTALL_PACKAGES="ffmpeg ffplay ffprobe xdg-utils"

. $(dirname $0)/common.sh

subst '1iAutoProv:no' $SPEC

# fix libdir
install_file /usr/lib/mozilla/native-messaging-hosts/net.downloadhelper.coapp.json /usr/lib64/mozilla/native-messaging-hosts/net.downloadhelper.coapp.json
remove_dir /usr/lib

#subst '1iAutoReq:no' $SPEC
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
