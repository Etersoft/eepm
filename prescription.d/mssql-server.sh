#!/bin/sh

# TODO: common place
fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

PKGNAME=mssql-server

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME mssql-tools msodbcsql17
    echo
    echo "Check data directory /var/opt/mssql if you need remove it too."
    exit
fi

[ "$1" != "--run" ] && echo "MS SQL Server 2019 from the official site" && exit

[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

if [ "$($DISTRVENDOR -d)" = "ALTLinux" ] ; then
    serv mssql-server stop
    epm install --repack https://packages.microsoft.com/rhel/8/mssql-server-2019/mssql-server-1*.x86_64.rpm || fatal
    epm install --repack https://packages.microsoft.com/rhel/8/prod/mssql-tools-1*.x86_64.rpm
    epm install --repack https://packages.microsoft.com/rhel/8/prod/msodbcsql17-1*.x86_64.rpm

    sudo /opt/mssql/bin/mssql-conf setup accept-eula

    epm install unixODBC
    sudo odbcinst -i -d -f /opt/microsoft/msodbcsql17/etc/odbcinst.ini
    sudo odbcinst -q -d

    serv mssql-server on
cat <<EOF

Use follow command to check the connection to the MS SQL server:
$ /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -Q 'sp_databases'
EOF
    exit
fi

fatal "We support only ALTLinux for now"
