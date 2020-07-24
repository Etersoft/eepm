#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

# we need libssl/libcrypto-devel due libssl.so/libcrypto.so using (ALT bug 35559)
REQUIRES="libssl-devel pbzip2 bzip2 gdb python-base libnuma libkrb5 libsss_nss_idmap cyrus-sasl2 libsasl2-plugin-gssapi procps"

subst "s|^\(Name: .*\)$|# FIXME: due libcrypto.so.10(libcrypto.so.10)(64bit) autoreqs\nAutoReq:yes,nolib\n# Converted from original package requires\nRequires:$REQUIRES\n\1|g" $SPEC

# Set correct path to sysctl
subst 's|sysctl|/sbin/sysctl|' $BUILDROOT/opt/mssql/bin/crash-support-functions.sh
