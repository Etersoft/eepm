#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

erc unpack $TAR && cd libsane* || fatal

mkdir -vp usr/share/doc/$PRODUCT
mv -v Version.html usr/share/doc/$PRODUCT
rm -v install-driver
#
mkdir -vp etc
mv -v config etc/sane.d
#
mkdir -vp etc/sane.d/dlls.d
echo "panakvs" >etc/sane.d/dlls.d/panakvs

sanelib=usr/lib64/sane
# fack hack
[ -d /usr/lib/x86_64-linux-gnu ] && sanelib=usr/lib/x86_64-linux-gnu/sane
mkdir -vp $sanelib

cp -v objects/scanlld.so $sanelib
for i in objects/libsane-* ; do
  cp -v $i $sanelib/
  s=$(basename $i | sed -e 's|\(libsane.*\.so\).*|\1|') #'
  ln -sv $(basename $i) $sanelib/$s.1
  ln -sv $(basename $i) $sanelib/$s
done


PKGNAME="$(basename $TAR | sed -e "s|libsane-panakvs|$PRODUCT|")"

erc pack $PKGNAME.tar etc usr

return_tar $PKGNAME.tar
