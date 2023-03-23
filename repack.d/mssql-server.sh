#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

# we need libssl/libcrypto-devel due libssl.so/libcrypto.so using (ALT bug 35559)
REQUIRES="python3 pbzip2 bzip2 gdb libnuma libkrb5 libsss_nss_idmap cyrus-sasl2 libsasl2-plugin-gssapi procps"

# ALT's su does not support -p last 20 years
subst "s|su -p |su |" $BUILDROOT/opt/mssql/lib/mssql-conf/invokesqlservr.sh

subst "1iAutoProv:no\nAutoReq:yes,nopython,nopython3\n# Converted from original package requires\nRequires:$REQUIRES\n" $SPEC

# fix typo
subst "s|Руѝѝкий|Русский|" $BUILDROOT/opt/mssql/lib/mssql-conf/mssqlconfhelper.py

# Set correct path to sysctl
subst 's|sysctl|/sbin/sysctl|' $BUILDROOT/opt/mssql/bin/crash-support-functions.sh
subst 's|/usr/bin/basename|/bin/basename|' $BUILDROOT/opt/mssql/bin/*.sh

epm assure patchelf || exit
for i in $BUILDROOT/opt/mssql/lib/libunwind-x86_64.so.8 ; do
    a= patchelf --set-rpath '$ORIGIN/' $i
done

epm install libnuma libsss_nss_idmap bzip2 cyrus-sasl2 libcom_err libkrb5 libldap libsasl2-plugin-gssapi python3 su glibc-utils liblzma
# sudo
