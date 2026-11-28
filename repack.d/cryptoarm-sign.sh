#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=cryptoarm-sign
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

add_electron_deps

add_bin_link_command
fix_desktop_file

# apparmor profile is only for Ubuntu 24+ with userns restrictions, the vendor installs it in postinstall
remove_file $PRODUCTDIR/resources/apparmor-profile

# CryptoPro CSP libraries (libcapi10, libcapi20, libcppcades, libcpcurl from /opt/cprocsp/lib/amd64):
# CryptoPro packages do not provide sonames and can't be installed from repositories
ignore_lib_requires libcapi10.so.4 libcapi20.so.4 libcppcades.so.2 libcpcurl.so.4

# license install/remove helper is started via pkexec
add_unirequires /usr/bin/pkexec
