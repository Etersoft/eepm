#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=vkcalls
PRODUCTDIR=/opt/vk-calls

. $(dirname $0)/common.sh

move_to_opt /usr/opt/vk-calls

subst '1iAutoProv:no' $SPEC

remove_file /usr/local/bin/$PRODUCT
add_bin_link_command

epm assure patchelf || exit

cd $BUILDROOT$PRODUCTDIR
for i in lib* $PRODUCT  ; do
    a= patchelf --set-rpath '$ORIGIN' $i
done

epm install --skip-installed libmfx || epm install 316139 || fatal "Can't install libmfx"

# if not Debian based
if [ ! -s /etc/ssl/certs/ca-certificates.crt ] ; then
    # ALT and Fedora based
    subst "s|/etc/ssl/certs/ca-certificates.crt|/etc/pki/tls/certs/ca-bundle.crt\x0\x0|" $BUILDROOT$PRODUCTDIR/libsentry.so
fi
