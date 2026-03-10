#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

erc -C opt/$PRODUCT $TAR || fatal

[ -n "$VERSION" ] || VERSION=$(echo "$URL" | awk -F'/' '{print $6}')
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt || fatal

# fix version for rpm: 4.0beta47 -> 4.0~beta47 (so 4.0 > 4.0~beta47)
RPMVERSION=$(echo "$VERSION" | sed 's/beta/~beta/')

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
version: $RPMVERSION
EOF

return_tar $PKGNAME.tar
