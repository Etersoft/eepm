#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh


# yucca_0.10.1_linux_amd64.tar.gz
erc unpack $TAR || fatal
cd yucca*

mkdir -p opt/yucca/data
mv yucca opt/yucca/

#systemd service
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

#work user
cat <<EOF | create_file lib/sysusers.d/yucca.conf
g yucca -
u yucca - "yucca" "/opt/yucca/data" "/bin/false"
EOF

#work permission's
cat <<EOF | create_file lib/tmpfiles.d/yucca.conf
d /opt/yucca/data 2775 yucca yucca -
EOF

# gen epmty config yucca.conf if not exist
# if [ ! -f /opt/yucca/yucca.toml ];then
# ./opt/yucca/yucca server --config emtpy --show-config | sed 's|data_dir = ""|data_dir = "/opt/yucca/data"|' > opt/yucca/yucca.toml
# else
# cat /opt/yucca/yucca.toml > opt/yucca/yucca.toml
# fi

PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt lib || fatal

return_tar $PKGNAME.tar
