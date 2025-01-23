#!/bin/sh

PKGNAME=mssql-tools
SUPPORTEDARCHES="x86_64"
DESCRIPTION="MS SQL Server sqlcmd and bcp from the official site"
URL="https://packages.microsoft.com/"

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME msodbcsql17
    exit
fi

. $(dirname $0)/common.sh

dname="$(epm print info -s)"
dversion="$(epm print info -v)"

case "$(epm print info -d)" in
  AstraLinux*)
    epm install --skip-installed unixodbc || fatal
    epm install https://packages.microsoft.com/debian/8/prod/pool/main/m/msodbcsql17/msodbcsql17_1*_amd64.deb
    epm install https://packages.microsoft.com/debian/8/prod/pool/main/m/mssql-tools/mssql-tools_1*_amd64.deb
    #epm install https://packages.microsoft.com/ubuntu/16.04/prod/pool/main/m/mssql-tools/mssql-tools_1*_amd64.deb
    #epm install https://packages.microsoft.com/ubuntu/16.04/prod/pool/main/m/msodbcsql17/msodbcsql17_1*_amd64.deb
    ;;
  ALTLinux)
    epm install --skip-installed unixODBC || fatal
    epm install --repack https://packages.microsoft.com/rhel/8/prod/Packages/m/mssql-tools-1*.x86_64.rpm
    epm install --repack https://packages.microsoft.com/rhel/8/prod/Packages/m/msodbcsql17-1*.x86_64.rpm
    ;;
  Debian|Ubuntu)
    epm install --skip-installed unixodbc || fatal
    epm install https://packages.microsoft.com/$dname/$dversion/prod/pool/main/m/msodbcsql17/msodbcsql17_1*_amd64.deb
    epm install https://packages.microsoft.com/$dname/$dversion/prod/pool/main/m/mssql-tools/mssql-tools_1*_amd64.deb
    ;;
  *)
    fatal "$(epm print info -d) is not supported yet."
    ;;
esac

esu odbcinst -i -d -f /opt/microsoft/msodbcsql17/etc/odbcinst.ini
esu odbcinst -q -d


cat <<EOF

Use follow command to check the connection to the MS SQL server:
$ /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -Q 'sp_databases'
EOF
