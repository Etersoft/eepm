#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"

. $(dirname $0)/common.sh

erc -C opt/$PRODUCT unpack "$TAR" || fatal

# create wrapper script
mkdir -p usr/bin
cat <<'EOFBIN' > usr/bin/$PRODUCT
#!/bin/sh
cd /opt/steamcmd
exec ./steamcmd.sh "$@"
EOFBIN
chmod 755 usr/bin/$PRODUCT

# no version in archive name, use date
VERSION="$(date +%Y%m%d)"
PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

cat <<EOF >$PKGNAME.tar.eepm.yaml
name: $PRODUCT
group: Games
license: Proprietary
url: https://developer.valvesoftware.com/wiki/SteamCMD
summary: Steam console client
description: Command-line version of the Steam client for downloading and running dedicated game servers.
EOF

return_tar $PKGNAME.tar
