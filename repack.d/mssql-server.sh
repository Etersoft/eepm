#!/bin/sh -x

# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

subst "s|^\(Name: .*\)$|# FIXME: due libcrypto.so.10(libcrypto.so.10)(64bit) autoreqs\nAutoReq:yes,nolib\n# Converted from original package requires\nRequires:libssl pbzip2 bzip2 gdb python-base libnuma libkrb5 libsss_nss_idmap\n\1|g" $SPEC
