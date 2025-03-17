#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

alpkg=$(basename $TAR)

VERSION="$(echo "$alpkg" | grep -o -P '[-_.][0-9][0-9]*([.]*[0-9])*' | head -n1 | sed -e 's|^[-_.]||')" #"

# Commented out: will not work due incorect name
# Hack for https://www.bitwig.com/dl/Bitwig%20Studio/5.3.2/installer_linux/
#[ -n "$VERSION" ] || VERSION="$(basename "$(dirname "$URL")" | grep -E "[0-9.]+")"

[ -n "$VERSION" ] || fatal "Can't get version from $TAR. We have almost no chance it will supported in alien."

PRODUCT="$(echo "$alpkg" | sed -e "s|[-_.]$VERSION.*||")"

    # set version as all between name and extension
    #local woext="$(echo "alpkg" | sed -e 's|\.tar.*||')"
    #if [ "$woext" != "$alpkg" ] ; then
    #    VERSION="$(echo "$woext" " | sed -e "s|^$PKGNAME[-_.]||")"
    #fi

pkgtype="$(erc type $alpkg)"
PKGNAME=$PRODUCT-$VERSION.$pkgtype
if [ "$pkgtype" = "tar" ] || [ "$pkgtype" = "tar.gz" ] || [ "$pkgtype" = "tgz" ] ; then
    # just rename supported formats
    if [ "$alpkg" != "$PKGNAME" ] ; then
        mv $alpkg $PKGNAME
    fi
else
    # converts directly unsupported formats
    PKGNAME=$PRODUCT-$VERSION.tar
    erc repack $alpkg $PKGNAME || fatal
fi

#if [ "$alpkg" != "$newalpkg" ] ; then
#   rm -f $verbose $alpkg
#   alpkg=$newalpkg
#   fi

# TODO: how to add to tarball?
cat <<EOF >$PKGNAME.eepm.yaml
name: $PRODUCT
version: $VERSION
upstream_file: $alpkg
EOF

return_tar $PKGNAME
