#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh


# yucca_0.10.1_linux_amd64.tar.gz
BASENAME=$(basename $TAR .tar.gz)

ln -s $TAR $BASENAME.tar.gz
erc unpack $BASENAME.tar.gz || fatal

mkdir -p opt/yucca
mv yucca opt/yucca/yucca

cat <<EOF | create_file lib/systemd/system/yucca.service
[Unit]
Description=Yucca https://yucca.app
Documentation=https://docs.yucca.app
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
User=yucca
Group=yucca
SyslogIdentifier=yucca
PIDFile=/run/yucca.pid
LimitNOFILE=1024
WorkingDirectory=/opt/yucca
ExecStart=/opt/yucca/yucca server --config /opt/yucca/yucca.toml
ExecStop=/bin/kill -s SIGTERM \$MAINPID
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt lib || fatal

return_tar $PKGNAME.tar
