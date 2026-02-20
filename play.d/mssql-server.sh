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

# Default year is 2019 (tracked in app-versions)
MSSQL_YEAR=2019

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

serv mssql-server stop

dname="$(epm print info -s)"
dversion="$(epm print info -v)"

case "$(epm print info -e)" in
  AstraLinuxSE/1.7)
    # libc++1 is available in Astra repos, no need for external Debian repo
    epm install libc++1
    epm install https://packages.microsoft.com/ubuntu/20.04/mssql-server-$MSSQL_YEAR/pool/main/m/mssql-server/mssql-server_1*_amd64.deb
    ;;
  AstraLinuxSE/1.8)
    epm install https://packages.microsoft.com/ubuntu/20.04/mssql-server-$MSSQL_YEAR/pool/main/m/mssql-server/mssql-server_1*_amd64.deb
    ;;
  ALTLinux/p10|ALTLinux/c10f2)
    epm install --repack https://packages.microsoft.com/rhel/8/mssql-server-$MSSQL_YEAR/Packages/m/mssql-server-[0-9]*.x86_64.rpm || fatal
    ;;
  ALTLinux*)
    epm install --repack https://packages.microsoft.com/rhel/9/mssql-server-$MSSQL_YEAR/Packages/m/mssql-server-[0-9]*.x86_64.rpm || fatal
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
