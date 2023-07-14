#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=vkcalls
PRODUCTDIR=/opt/vk-calls

. $(dirname $0)/common.sh

move_to_opt /usr/opt/vk-calls

set_autoreq 'yes'

remove_file /usr/local/bin/$PRODUCT
add_bin_link_command

if epm assure patchelf ; then
for i in .$PRODUCTDIR/lib* .$PRODUCTDIR/$PRODUCT  ; do
    a= patchelf --set-rpath '$ORIGIN' $i
done
fi

# https://git.altlinux.org/tasks/316139
epm install --skip-installed --no-remove libmfx || epm install --no-remove 316139 || fatal "Can't install libmfx"

# if not Debian based
if [ ! -s /etc/ssl/certs/ca-certificates.crt ] ; then
    # ALT and Fedora based
    subst "s|/etc/ssl/certs/ca-certificates.crt|/etc/pki/tls/certs/ca-bundle.crt\x0\x0|" $BUILDROOT$PRODUCTDIR/libsentry.so
fi

# from vkcalls support
mkdir -p etc/tmpfiles.d/
cat >etc/tmpfiles.d/$PRODUCT.conf <<EOF
#Type	Path				Mode	User	Group	Age	Argument
f	/var/lock/vkcallsrelease.pid	0666	root	root	-	-
EOF
pack_file /etc/tmpfiles.d/$PRODUCT.conf
