#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

#REQUIRES="libcurl-gnutls-compat postgresql"
#PREINSTALL_PACKAGES="libcurl libsqlite3 libX11 libxml2 zlib $REQUIRES"

. $(dirname $0)/common.sh

# hack due broken provides in libcurl-gnutls-compat
ignore_lib_requires "libcurl-gnutls.so.4"
add_requires "libcurl-gnutls.so.4(64bit)"

add_libs_requires

exit

# ошибка: Неудовлетворенные зависимости:
#    libcurl.so.4(CURL_OPENSSL_3)(64bit) нужен для sbb-02.008.02-alt1.repacked.with.epm.20.x86_64

subst '1i%filter_from_requires /^libcurl.so.4(CURL_OPENSSL_.*/d' $SPEC
subst '1i%filter_from_requires /^libcurl-gnutls.so.4(CURL_GNUTLS_.*/d' $SPEC

add_requires $REQUIRES

set_autoreq 'yes'
