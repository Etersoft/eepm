#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=ipera-mediaserver
PRODUCTDIR=/opt/ipera/mediaserver

. $(dirname $0)/common.sh

remove_dir /etc/init

epm assure patchelf || exit
cd $BUILDROOT$PRODUCTDIR || exit
for i in lib/lib*.so.* ; do
    a= patchelf --set-rpath '$ORIGIN' $i
done

for i in bin/plugins_optional/lib*.so bin/plugins/lib*.so ; do
    a= patchelf --set-rpath '$ORIGIN/../../lib' $i
done

filter_from_requires "libldap_r-2.4.so.2(OPENLDAP_2.*)(64bit)" "liblber-2.4.so.2(OPENLDAP_2.*)(64bit)" "ld-linux-.*(GLIBC_PRIVATE)"
filter_from_requires libQt5 libGL libicu
