#!/bin/sh

PKGNAME="mssql-tools msodbcsql17"
SUPPORTEDARCHES="x86_64"
DESCRIPTION="MS SQL Server sqlcmd and bcp from the official site"
URL="https://packages.microsoft.com/"

. $(dirname $0)/common.sh

dname="$(epm print info -s)"
dversion="$(epm print info -v)"

ODBCDRIVER="ODBC Driver 17 for SQL Server"

# msodbcsql17 preinst refuses to install if the driver is already registered in /etc/odbcinst.ini:
# drop the stale registration left after removal of msodbcsql17 (eterbug #19294)
if ! epm status --installed msodbcsql17 ; then
    for i in 1 2 3 4 5 ; do
        a='' odbcinst -q -d -n "$ODBCDRIVER" >/dev/null 2>&1 || break
        esu odbcinst -u -d -n "$ODBCDRIVER"
    done
fi

case "$(epm print info -e)" in
  AstraLinuxSE/1.7)
    epm install --skip-installed unixodbc || fatal
    epm install "https://packages.microsoft.com/ubuntu/18.04/prod/pool/main/m/msodbcsql17/msodbcsql17_1*_amd64.deb" || fatal
    epm install "https://packages.microsoft.com/ubuntu/18.04/prod/pool/main/m/mssql-tools/mssql-tools_1*_amd64.deb" || fatal
    ;;
  AstraLinuxSE/1.8)
    epm install --skip-installed unixodbc || fatal
    epm install "https://packages.microsoft.com/debian/12/prod/pool/main/m/msodbcsql17/msodbcsql17_1*_amd64.deb" || fatal
    epm install "https://packages.microsoft.com/debian/12/prod/pool/main/m/mssql-tools/mssql-tools_1*_amd64.deb" || fatal
    ;;
  ALTLinux*|ROSA/*|RedOS/*|Fedora/*)
    epm install --skip-installed unixODBC || fatal
    epm install --repack "https://packages.microsoft.com/rhel/8/prod/Packages/m/mssql-tools-1*.x86_64.rpm" || fatal
    epm install --repack "https://packages.microsoft.com/rhel/8/prod/Packages/m/msodbcsql17-1*.x86_64.rpm" || fatal
    ;;
  Debian*|Ubuntu*)
    epm install --skip-installed unixodbc || fatal
    epm install "https://packages.microsoft.com/$dname/$dversion/prod/pool/main/m/msodbcsql17/msodbcsql17_1*_amd64.deb" || fatal
    epm install "https://packages.microsoft.com/$dname/$dversion/prod/pool/main/m/mssql-tools/mssql-tools_1*_amd64.deb" || fatal
    ;;
  *)
    fatal "$(epm print info -d) is not supported yet."
    ;;
esac

# the driver is registered by msodbcsql17 postinst (not run for repacked packages)
a='' odbcinst -q -d -n "$ODBCDRIVER" >/dev/null 2>&1 || esu odbcinst -i -d -f /opt/microsoft/msodbcsql17/etc/odbcinst.ini
esu odbcinst -q -d


cat <<EOF

Use follow command to check the connection to the MS SQL server:
$ /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -Q 'sp_databases'
EOF
