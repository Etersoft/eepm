#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
#VERSION="$3"

. $(dirname $0)/common.sh

# meridius-3.1.0.tar.gz
PKGNAME="$(basename "$TAR" .tar.gz)"

mkdir opt/
erc $TAR
mv -v $PRODUCT* opt/$PRODUCT

erc a $PKGNAME.tar opt

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/WWW
license: Shareware
url: https://github.com/PurpleHorrorRus/Meridius
summary: Music Player for vk.com based on Electron, NuxtJS, Vue
description: Music Player for vk.com based on Electron, NuxtJS, Vue.
EOF

return_tar $PKGNAME.tar
