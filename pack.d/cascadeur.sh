#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION

if echo "$TAR" | grep -q "cascadeur-linux.tgz" ; then
    erc "$TAR" || fatal
else
    fatal "We support only cascadeur-linux.tgz"
fi

mkdir opt
mv cascadeur* opt/$PRODUCT || fatal

# from https://www.producthunt.com/posts/cascadeur
# QmQLQK6byKKzvvHEA84h4Auxci1o9T6bCQQikZFgRM8KBx
install_file "https://ph-files.imgix.net/e07b5249-d804-4b4e-9458-fa037d30a14b.png?auto=compress&codec=mozjpeg&cs=strip&auto=format&w=72&h=72&fit=crop&bg=0fff&dpr=1" /usr/share/pixmaps/$PRODUCT.png

erc pack $PKGNAME.tar opt usr

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Graphics
license: Proprietary
url: https://cascadeur.com/download
summary: Cascadeur - a physics‑based 3D animation software
description: Cascadeur - a physics‑based 3D animation software.
EOF

return_tar $PKGNAME.tar
