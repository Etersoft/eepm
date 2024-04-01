#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
#VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME="$(basename "$TAR" | sed -e "s|sublime_text_build_|$PRODUCT-|" -e 's|_.*||' )"

mkdir opt/
erc $TAR
mv -v sublime* opt/$PRODUCT

erc a $PKGNAME.tar opt

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Text tools
license: Proprietary
url: https://www.sublimetext.com
summary: Sophisticated text editor for code, html and prose
description: Sophisticated text editor for code, html and prose.
EOF

return_tar $PKGNAME.tar
