#!/bin/sh

PKGNAME=mssql-server-fts
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="MS SQL Server Full Text Search"
URL="https://www.minecraft.net/en-us/download"

. $(dirname $0)/common.sh

warn_version_is_not_supported

PKGURL=$(eget --list --latest "https://packages.microsoft.com/sles/12/mssql-server-2019/Packages/m/" "mssql-server-fts*.x86_64.rpm")

install_pkgurl

cat <<EOF

Run follow commands manually for complete the setup:
# /opt/mssql/bin/mssql-conf welcome fts
EOF
