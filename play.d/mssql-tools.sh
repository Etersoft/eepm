#!/bin/sh

PKGNAME=mssql-tools
DESCRIPTION="MS SQL Server sqlcmd and bcp from the official site"

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME msodbcsql17
    exit
fi

. $(dirname $0)/common.sh

[ "$1" != "--run" ] && echo "MS SQL Server sqlcmd and bcp from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

case "$($DISTRVENDOR -d)" in
  "AstraLinux")
    epm install https://packages.microsoft.com/debian/8/prod/pool/main/m/msodbcsql17/msodbcsql17_1*_amd64.deb
    epm install https://packages.microsoft.com/debian/8/prod/pool/main/m/mssql-tools/mssql-tools_1*_amd64.deb
    #epm install https://packages.microsoft.com/ubuntu/16.04/prod/pool/main/m/mssql-tools/mssql-tools_1*_amd64.deb
    #epm install https://packages.microsoft.com/ubuntu/16.04/prod/pool/main/m/msodbcsql17/msodbcsql17_1*_amd64.deb
    epm install unixodbc
    ;;
  "ALTLinux")
    epm install --repack https://packages.microsoft.com/rhel/8/prod/mssql-tools-1*.x86_64.rpm
    epm install --repack https://packages.microsoft.com/rhel/8/prod/msodbcsql17-1*.x86_64.rpm
    epm install unixODBC
    ;;
  *)
    fatal "$(DISTRVENDOR -d) is not supported yet."
    ;;
esac

$SUDO odbcinst -i -d -f /opt/microsoft/msodbcsql17/etc/odbcinst.ini
$SUDO odbcinst -q -d


cat <<EOF

Use follow command to check the connection to the MS SQL server:
$ /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -Q 'sp_databases'
EOF
