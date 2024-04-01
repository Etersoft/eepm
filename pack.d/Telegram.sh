#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
FPRODUCT="Telegram"
TPRODUCT="Telegram"

. $(dirname $0)/common.sh

erc $TAR || fatal

# use version from tarball
# (TODO: get basename via erc
PKGNAME="$(basename $TAR .tar.xz | sed -e "s|^tsetup|$PRODUCT|" )"
#PKGNAME="$(basename $PKGNAME .zip | )"

f=$FPRODUCT
[ -f "$(echo */$FPRODUCT)" ] && f="$(echo */$FPRODUCT)"

install -D -m755 $f opt/$TPRODUCT/$TPRODUCT || fatal
erc pack $PKGNAME.tar opt/$TPRODUCT

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Instant messaging
license: GPLv2
url: https://desktop.telegram.org/
summary: Telegram Desktop messaging app
description: Telegram Desktop messaging app.
EOF

return_tar $PKGNAME.tar
