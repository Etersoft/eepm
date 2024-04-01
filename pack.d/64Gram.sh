#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
FPRODUCT="Telegram"

. $(dirname $0)/common.sh

erc $TAR || fatal

# use version from tarball
# (TODO: get basename via erc
PKGNAME="$(basename $TAR .zip | sed -e "s|_linux||" )"

f=$FPRODUCT
[ -f "$(echo */$FPRODUCT)" ] && f="$(echo */$FPRODUCT)"

install -D -m755 $f opt/$PRODUCT/$PRODUCT || fatal
erc pack $PKGNAME.tar opt/$PRODUCT

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Instant messaging
license: GPLv2
url: https://github.com/TDesktop-x64/tdesktop
summary: 64Gram (unofficial Telegram Desktop)
description: 64Gram (unofficial Telegram Desktop).
EOF

return_tar $PKGNAME.tar
