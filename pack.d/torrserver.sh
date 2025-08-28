#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

PKGNAME=$PRODUCT-$VERSION

mkdir -p var/lib/torrserver
mkdir -p usr/bin
mv -v $TAR usr/bin/torrserver

chmod 755 usr/bin/torrserver

cat <<EOF | create_file /usr/lib/systemd/system/torrserver.service
[Unit]
Description = TorrServer
After = syslog.target network.target nss-lookup.target

[Service]
Type = simple
Environment="GODEBUG=madvdontneed=1"
ExecStart = /usr/bin/torrserver -d /var/lib/torrserver
ExecReload = /bin/kill -HUP ${MAINPID}
ExecStop = /bin/kill -INT ${MAINPID}
TimeoutSec = 30
Restart = on-failure
LimitNOFILE = 4096

[Install]
WantedBy = multi-user.target
EOF

erc pack $PKGNAME.tar usr var

return_tar $PKGNAME.tar
