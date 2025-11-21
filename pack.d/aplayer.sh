#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

# aplayer64.tar.gz
BASENAME=$(basename "$1" .tar.gz | sed -E 's/(64|-arm64)$//')
mkdir -p opt/aplayer
mkdir -p usr/

erc unpack $TAR || fatal

mv aplayer/* opt/aplayer/

# setup icon
mkdir -p usr/share/pixmaps/
mv opt/aplayer/img/logo.png usr/share/pixmaps/aplayer.png

# setup bin
mkdir -p usr/bin
chmod 755 opt/aplayer/aplayer
mv opt/aplayer/aplayer usr/bin/

# setup desktop file
mkdir -p usr/share/applications/
sed -i 's/^Icon=.*/Icon=aplayer/' opt/aplayer/aplayer.desktop
sed -i 's/^Exec=.*/Exec=aplayer %F/' opt/aplayer/aplayer.desktop
mv opt/aplayer/aplayer.desktop usr/share/applications/

# setup service
rm opt/aplayer/aplayer_root.sh
rm opt/aplayer/aplayer.service

mkdir -p usr/lib/systemd/system/
cat << 'EOF' > usr/lib/systemd/system/aplayer.service
[Unit]
Description=Album Player Service

[Service]
Type=forking
ExecStart=aplayer
StandardOutput=null

[Install]
WantedBy=multi-user.target
EOF

# fix problematic filenames ([176]HR4.wav 100% Românesc.rad)
find opt/aplayer -depth | while IFS= read -r f; do
    dir=$(dirname "$f")
    base=$(basename "$f")
    new="$base"
    new=$(echo "$new" | sed 's/%/_/g; s/ /_/g')
    new=$(echo "$new" | sed 's/\[/_/g; s/\]/_/g')
    if [ "$new" != "$base" ]; then
        mv "$f" "$dir/$new"
    fi
done


PKGNAME=$PRODUCT-$VERSION

erc pack $PKGNAME.tar opt usr || fatal

return_tar $PKGNAME.tar
