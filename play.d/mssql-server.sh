#!/bin/sh

PKGNAME=mssql-server
SUPPORTEDARCHES="x86_64"
VERSION="$2"
DESCRIPTION="MS SQL Server from the official site"
URL="https://packages.microsoft.com/"
TIPS="Run 'epm play mssql-server=2022' to install other year (2017, 2019, 2022, 2025, preview)."

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    echo
    echo "Check data directory /var/opt/mssql if you need remove it too."
    exit
fi

. $(dirname $0)/common.sh

# Default year is 2022 (tracked in app-versions)
MSSQL_YEAR=2022

case "$VERSION" in
    2017|2019|2022|2025|preview)
        MSSQL_YEAR="$VERSION"
        VERSION="*"
        ;;
    ""|"*")
        ;;
    *)
        warn_version_is_not_supported
        ;;
esac

# RHEL repo version matrix:
#          rhel/8  rhel/9
# 2017      +       -
# 2019      +       -
# 2022      +       +
# 2025      -       +
# preview   +       +
#
# Ubuntu repo version matrix:
#          16.04  18.04  20.04  22.04  24.04
# 2017      +      +      -      -      -
# 2019      +      +      +      -      -
# 2022      -      -      +      +      -
# 2025      -      -      -      +      +
# preview   +      -      +      +      +
case "$MSSQL_YEAR" in
    2017|2019) RHEL_VERSION=8 ;;
    *)         RHEL_VERSION=9 ;;
esac

serv mssql-server stop

dname="$(epm print info -s)"
dversion="$(epm print info -v)"

case "$(epm print info -e)" in
  AstraLinuxSE/1.7)
    # only 2017 and 2019 are available for Ubuntu 18.04
    [ "$MSSQL_YEAR" = "2022" ] && MSSQL_YEAR=2019
    # libc++1 is available in Astra repos, no need for external Debian repo
    epm install libc++1
    epm install --repack https://packages.microsoft.com/ubuntu/18.04/mssql-server-$MSSQL_YEAR/pool/main/m/mssql-server/mssql-server_1*_amd64.deb
    ;;
  AstraLinuxSE/1.8)
    epm install --repack https://packages.microsoft.com/ubuntu/20.04/mssql-server-$MSSQL_YEAR/pool/main/m/mssql-server/mssql-server_1*_amd64.deb
    ;;
  ALTLinux/p10|ALTLinux/c10f2)
    epm install --repack https://packages.microsoft.com/rhel/8/mssql-server-$MSSQL_YEAR/Packages/m/mssql-server-[0-9]*.x86_64.rpm || fatal
    ;;
  ALTLinux*)
    epm install --repack https://packages.microsoft.com/rhel/$RHEL_VERSION/mssql-server-$MSSQL_YEAR/Packages/m/mssql-server-[0-9]*.x86_64.rpm || fatal
    ;;
  Ubuntu*)
    epm install https://packages.microsoft.com/$dname/$dversion/mssql-server-$MSSQL_YEAR/pool/main/m/mssql-server/mssql-server_1*_amd64.deb
    ;;
  *)
    fatal "$(epm print info -d) is not supported yet."
    ;;
esac

# fix ownership after install/repack (mssql-conf setup needs write access)
esu chown -R mssql:mssql /var/opt/mssql/

if [ -z "$auto" ] ; then
    esu /opt/mssql/bin/mssql-conf setup accept-eula
    serv mssql-server on
else
cat <<EOF
Run follow commands manually for complete the setup:
    # /opt/mssql/bin/mssql-conf setup accept-eula
    # serv mssql-server on
EOF
fi


cat <<EOF

Use follow command to check the connection to the MS SQL server:
$ /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -Q 'sp_databases'
EOF
