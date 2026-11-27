#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=cryptoarm-gost-mail
PRODUCTDIR=/opt/cryptoarm_gost_mail

. $(dirname $0)/common.sh

# Release: .ct7 (rpm-build does not allow '..' in epm1.repacked..ct7)
subst "s|^\(Release: .*\)\.\.|\1.|" $SPEC

add_electron_deps

add_bin_link_command $PRODUCT $PRODUCTDIR/$PRODUCT
fix_desktop_file $PRODUCTDIR/$PRODUCT $PRODUCT

# the license file is written there by the application (as in the vendor's postinstall)
LICDIR="/etc/opt/Trusted/CryptoARM GOST 3"
mkdir -p "$BUILDROOT$LICDIR"
subst "s|%files|%files\n%attr(0777,root,root) %dir \"$LICDIR\"|" $SPEC

# CryptoPro CSP libraries (libcapi10, libcapi20, libcades, libcpcurl from /opt/cprocsp/lib/amd64):
# CryptoPro packages do not provide sonames and can't be installed from repositories
ignore_lib_requires libcapi10.so.4 libcapi20.so.4 libcades.so.2 libcpcurl.so.4

# native Node modules (*.node) are not executable, so they are not scanned for requires
# trusted_mailcore2.node
add_unirequires libsasl2.so.3 libuuid.so.1
