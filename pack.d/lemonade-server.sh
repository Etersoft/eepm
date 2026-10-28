#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

[ -d "$TAR" ] || fatal "Expected a directory with Lemonade packages"
RPM="$(find "$TAR" -maxdepth 1 -type f -name '*.rpm' | head -n1)"
EMBED="$(find "$TAR" -maxdepth 1 -type f -name '*embeddable*.tar.gz' | head -n1)"
[ -n "$RPM" ] || fatal "Can't find Lemonade RPM"
[ -n "$EMBED" ] || fatal "Can't find Lemonade embeddable archive"

epm assure patool || fatal
epm assure cpio || fatal
epm assure zstd || fatal
mkdir rpm embeddable || fatal
erc -C rpm unpack "$RPM" || fatal
erc -C embeddable unpack "$EMBED" || fatal

# Some patool backends unpack RPM only to its inner cpio payload.
if [ ! -x rpm/opt/bin/lemonade ] ; then
    RPMPAYLOAD="$(find rpm -type f -name '*.cpio.*' | head -n1)"
    [ -z "$RPMPAYLOAD" ] || erc -C rpm unpack "$RPMPAYLOAD" || fatal
fi
if [ ! -x rpm/opt/bin/lemonade ] ; then
    RPMPAYLOAD="$(find rpm -type f -name '*.cpio' | head -n1)"
    [ -n "$RPMPAYLOAD" ] || fatal "Can't find Lemonade cpio payload"
    erc -C rpm unpack "$RPMPAYLOAD" || fatal
fi

[ -x rpm/opt/bin/lemonade ] || fatal "Can't find Lemonade RPM payload"
[ -x embeddable/lemonade ] || fatal "Can't find embeddable lemonade"
[ -x embeddable/lemond ] || fatal "Can't find embeddable lemond"

cp -a rpm/. . || fatal
cp -a embeddable/lemonade embeddable/lemond opt/bin/ || fatal

erc pack "$PKGNAME.tar" opt usr etc || fatal

cat <<EOF >"$PKGNAME.tar.eepm.yaml"
name: $PRODUCT
group: Development/Other
license: Apache-2.0
url: https://github.com/lemonade-sdk/lemonade
summary: Local LLM server with GPU and NPU acceleration
description: Lemonade is a local LLM server with GPU and NPU acceleration.
EOF

return_tar "$PKGNAME.tar"
