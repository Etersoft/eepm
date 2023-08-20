#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

#PREINSTALL_PACKAGES="coreutils gawk libapr1 libaprutil1 libcares libcrypt libcrypto1.1 libcurl liblame libldap libncurses libnghttp2 libnsl1 libpcre3 libpng16 libpq5 libreadline7 libspeex libssl1.1 libtinfo libxml2 systemd-utils zlib"

. $(dirname $0)/common.sh

#  trueconf-server: Требует: libcurl.so.4(CURL_OPENSSL_4)(64bit) но пакет не может быть установлен
#                   Требует: liblber-2.4.so.2(OPENLDAP_2.4_2)(64bit) но пакет не может быть установлен
#                   Требует: libldap_r-2.4.so.2(OPENLDAP_2.4_2)(64bit) но пакет не может быть установлен

#subst '1i%filter_from_requires /^libcurl.so.4(CURL_OPENSSL_.*/d' $SPEC
#subst '1i%filter_from_requires /^liblber-2.4.so.2(OPENLDAP_.*/d' $SPEC
#subst '1i%filter_from_requires /^libldap_r-2.4.so.2(OPENLDAP_.*/d' $SPEC

add_libs_requires
