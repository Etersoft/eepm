#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=ipera-mediaserver
PRODUCTDIR=/opt/ipera/mediaserver

. $(dirname $0)/common.sh

remove_dir /etc/init

if epm assure patchelf ; then
cd $BUILDROOT$PRODUCTDIR || exit
for i in lib/lib*.so.* ; do
    a= patchelf --set-rpath '$ORIGIN' $i
done

for i in bin/plugins_optional/lib*.so bin/plugins/lib*.so ; do
    a= patchelf --set-rpath '$ORIGIN/../../lib' $i
done
fi

filter_from_requires "libldap_r-2.4.so.2(OPENLDAP_2.*)(64bit)" "liblber-2.4.so.2(OPENLDAP_2.*)(64bit)" "ld-linux-.*(GLIBC_PRIVATE)"
filter_from_requires libQt5 libGL libicu

cd $BUILDROOT || exit
mkdir -p var/lib/ipera
pack_dir /var/lib/ipera
ln -s /var/lib/ipera .$PRODUCTDIR/var
pack_file $PRODUCTDIR/var

set_autoreq 'yes'
