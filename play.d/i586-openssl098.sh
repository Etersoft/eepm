#!/bin/sh

PKGNAME="eepm-i586-libcrypto7 eepm-i586-libssl7"
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="OpenSSL 0.9.8 (libcrypto.so.0.9.8, libssl.so.0.9.8) from ALT repo"
DESCRIPTION=''
URL="https://packages.altlinux.org/ru/sisyphus/srpms/openssl098/rpms/"

. $(dirname $0)/common.sh

[ "$(epm print info -s)" = "alt" ] || fatal "only ALT is supported."

# see also https://github.com/M0Rf30/openssl098-lib32/

# https://git.altlinux.org/tasks/154980/build/repo/x86_64-i586/RPMS.task/i586-libcrypto7-0.9.8zh-alt1.i586.rpm
PKGURL1="ipfs://QmdDE7qAZQPESmTmuqqVYyeBKcyTjo8N7SrZ81ZzVQREBi?filename=i586-libcrypto7-0.9.8zh-alt1.i586.rpm"

# https://git.altlinux.org/tasks/154980/build/repo/x86_64-i586/RPMS.task/i586-libssl7-0.9.8zh-alt1.i586.rpm
PKGURL2="ipfs://QmWRqtjU4FM1v2nU9rs4E8fJww7BxDevRNSA6RUi38PM6D?filename=i586-libssl7-0.9.8zh-alt1.i586.rpm"

epm install --repack $PKGURL1 $PKGURL2
