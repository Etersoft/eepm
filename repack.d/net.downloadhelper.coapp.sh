#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"

SPEC="$2"


. $(dirname $0)/common.sh

subst '1iAutoReq:no' $SPEC
subst '1iAutoProv:no' $SPEC

# fix libdir
install_file /usr/lib/mozilla/native-messaging-hosts/net.downloadhelper.coapp.json /usr/lib64/mozilla/native-messaging-hosts/net.downloadhelper.coapp.json
remove_dir /usr/lib

