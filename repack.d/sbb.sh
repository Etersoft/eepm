#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

# ошибка: Неудовлетворенные зависимости:
#    libcurl.so.4(CURL_OPENSSL_3)(64bit) нужен для sbb-02.008.02-alt1.repacked.with.epm.20.x86_64

subst '1i%filter_from_requires /^libcurl.so.4(CURL_OPENSSL_.*/d' $SPEC
subst '1i%filter_from_requires /^libcurl-gnutls.so.4(CURL_GNUTLS_.*/d' $SPEC

REQUIRES="libcurl-gnutls-compat postgresql"
subst "1iRequires:$REQUIRES" $SPEC

# install all requires packages before packing (the list have got with rpmreqs anydesk)
epm install --skip-installed libcurl libsqlite3 libX11 libxml2 zlib $REQUIRES
