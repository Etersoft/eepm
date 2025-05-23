#!/bin/sh

PKGNAME=mssql-server
SUPPORTEDARCHES="x86_64"
DESCRIPTION="MS SQL Server 2019 from the official site"
URL="https://packages.microsoft.com/"

if [ "$1" = "--remove" ] ; then
    epm remove $PKGNAME
    echo
    echo "Check data directory /var/opt/mssql if you need remove it too."
    exit
fi

. $(dirname $0)/common.sh


serv mssql-server stop

dname="$(epm print info -s)"
dversion="$(epm print info -v)"

case "$(epm print info -e)" in
  AstraLinuxSE/1.7)
    DEBREPO="deb http://ftp.ru.debian.org/debian/ stretch main"
    # we have libc++1-9, but this package requires libc++1
    epm ar $DEBREPO ; epm update
    epm install libc++1
    epm install https://packages.microsoft.com/ubuntu/20.04/mssql-server-2019/pool/main/m/mssql-server/mssql-server_1*_amd64.deb
    epm rr $DEBREPO ; epm update
    ;;
  AstraLinuxSE/1.8)
    epm install https://packages.microsoft.com/debian/12/mssql-server-2019/pool/main/m/mssql-server/mssql-server_1*_amd64.deb
    ;;
  ALTLinux/p10|ALTLinux/c10f2)
    epm install --repack https://packages.microsoft.com/rhel/8/mssql-server-2019/Packages/m/mssql-server-[0-9]*.x86_64.rpm || fatal
    ;;
  ALTLinux*)
    epm install --repack https://packages.microsoft.com/rhel/9/mssql-server-2022/Packages/m/mssql-server-[0-9]*.x86_64.rpm || fatal
    ;;
  Ubuntu*)
    epm install https://packages.microsoft.com/$dname/$dversion/mssql-server-2022/pool/main/m/mssql-server/mssql-server_1*_amd64.deb
    ;;
  *)
    fatal "$(epm print info -d) is not supported yet."
    ;;
esac

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
