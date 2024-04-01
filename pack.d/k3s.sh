#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION

install -D $TAR usr/bin/$PRODUCT || fatal
for i in kubectl crictl ctr k3s ; do
    ln -sf $PRODUCT usr/bin/$i
done
erc pack $PKGNAME.tar usr/bin

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: File tools
license: Apache-2.0
url: https://k3s.io
summary: K3s - Lightweight Kubernetes
description: K3s - Lightweight Kubernetes.
EOF

return_tar $PKGNAME.tar
