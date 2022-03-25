#!/bin/sh

PKGNAME=mssql-server
DESCRIPTION="MS SQL Server 2019 from the official site"

DEBREPO="deb http://ftp.ru.debian.org/debian/ stretch main"

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    echo
    echo "Check data directory /var/opt/mssql if you need remove it too."
    exit
fi

. $(dirname $0)/common.sh


[ "$($DISTRVENDOR -a)" != "x86_64" ] && echo "Only x86_64 is supported" && exit 1

serv mssql-server stop

case "$($DISTRVENDOR -d)" in
  "AstraLinux")
    # we have libc++1-9, but this package requires libc++1
    epm ar $DEBREPO ; epm update
    epm install libc++1
    epm install https://packages.microsoft.com/ubuntu/20.04/mssql-server-2019/pool/main/m/mssql-server/mssql-server_1*_amd64.deb
    epm rr $DEBREPO ; epm update
    ;;
  "ALTLinux")
    epm install --repack https://packages.microsoft.com/rhel/8/mssql-server-2019/mssql-server-1*.x86_64.rpm || fatal
    ;;
  *)
    fatal "$(DISTRVENDOR -d) is not supported yet."
    ;;
esac

$SUDO /opt/mssql/bin/mssql-conf setup accept-eula

serv mssql-server on


cat <<EOF

Use follow command to check the connection to the MS SQL server:
$ /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -Q 'sp_databases'
EOF
