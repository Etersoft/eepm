#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=ipera-mediaserver
PRODUCTDIR=/opt/ipera/mediaserver

. $(dirname $0)/common.sh

remove_dir /etc/init

# see https://bugzilla.altlinux.org/47890
# hack due broken provides in libcurl-gnutls-compat
ignore_lib_requires "libcurl-gnutls.so.4"
add_requires "libcurl-gnutls.so.4(64bit)"

ignore_lib_requires "libnx_clusterdb_engine.so"

add_libs_requires

mkdir -p var/lib/ipera
pack_dir /var/lib/ipera
ln -s /var/lib/ipera .$PRODUCTDIR/var
pack_file $PRODUCTDIR/var

