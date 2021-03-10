#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

# reenable console output
subst 's| > /dev/null 2>&1||' $BUILDROOT/opt/pt/packettracer

subst '1iAutoProv:no' $SPEC
subst '1iAutoReq:yes,nopython' $SPEC

#REQUIRES="libcurl libldap"
#subst "1iRequires:$REQUIRES|" $SPEC

# install all requires packages before packing (the list have got with rpmreqs anydesk)
#epm install --skip-installed coreutils gawk libapr1 libaprutil1 libcares libcrypt libcrypto1.1 libcurl liblame libldap libncurses libnghttp2 libnsl1 libpcre3 libpng16 libpq5 libreadline7 libspeex libssl1.1 libtinfo libxml2 mozldap systemd-utils veyon zlib
