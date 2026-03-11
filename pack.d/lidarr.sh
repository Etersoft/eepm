#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"
URL="$4"

. $(dirname $0)/common.sh

[ -n "$VERSION" ] || VERSION="$(basename "$TAR" | sed -E 's/^[^.]+\.[^.]+\.(.+)\.linux.*/\1/')"
[ -n "$VERSION" ] || fatal "Can't get package version"

PKGNAME=$PRODUCT-$VERSION

erc -C opt/$PRODUCT unpack "$TAR" || fatal

# Create launcher script
cat <<'EOF' | create_file usr/bin/$PRODUCT
#!/bin/sh
exec /opt/lidarr/Lidarr -nobrowser "$@"
EOF
chmod 755 usr/bin/$PRODUCT

# Create systemd service
cat <<EOF | create_file usr/lib/systemd/system/$PRODUCT.service
[Unit]
Description=Lidarr Daemon
After=syslog.target network.target

[Service]
User=$PRODUCT
Group=media
Type=simple
ExecStart=/opt/$PRODUCT/Lidarr -nobrowser -data=/var/lib/$PRODUCT/
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Create sysusers.d config for user creation
cat <<EOF | create_file usr/lib/sysusers.d/$PRODUCT.conf
u $PRODUCT - "Lidarr service" /var/lib/$PRODUCT
EOF

# Create tmpfiles.d config for directories
cat <<EOF | create_file usr/lib/tmpfiles.d/$PRODUCT.conf
d /var/lib/$PRODUCT 0750 $PRODUCT media -
EOF

erc pack $PKGNAME.tar opt usr

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Networking/Other
license: GPLv3
url: https://lidarr.audio/
summary: Music library manager
description: Lidarr is a music collection manager for Usenet and BitTorrent users.
requires: curl mediainfo sqlite3 libchromaprint-tools
EOF

return_tar $PKGNAME.tar
