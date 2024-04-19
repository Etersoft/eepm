#!/bin/sh -x

BUILDROOT="$1"
SPEC="$2"

PRODUCT=Trezor-Suite
PRODUCTDIR=/opt/$PRODUCT

. $(dirname $0)/common.sh

subst "s|^License: unknown$|License: T-RSL|" $SPEC
subst "s|^Summary:.*|Summary: Management software for Trezor hardware cryptocurrency wallets|" $SPEC

epm tool eget -O - https://data.trezor.io/udev/51-trezor.rules | create_file /etc/udev/rules.d/51-trezor.rules

ignore_lib_requires liblog.so libm.so libdl.so libc.so libc++_shared.so libc.musl-x86_64.so.1

add_libs_requires
