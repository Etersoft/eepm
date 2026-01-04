#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

mkdir -p opt/steamcmd/linux32
mkdir -p usr/bin

erc unpack $TAR || fatal

ls -R steamcmd_linux

# base
mv "steamcmd_linux/steamcmd.sh" "opt/steamcmd/steamcmd.sh"

# linux32
mv "steamcmd_linux/linux32/crashhandler.so"      "opt/steamcmd/linux32/crashhandler.so"
mv "steamcmd_linux/linux32/libstdc++.so.6"       "opt/steamcmd/linux32/libstdc++.so.6"
mv "steamcmd_linux/linux32/steamcmd"              "opt/steamcmd/linux32/steamcmd"
mv "steamcmd_linux/linux32/steamerrorreporter"    "opt/steamcmd/linux32/steamerrorreporter"

cat <<EOF > usr/bin/steamcmd
#!/bin/sh
# Copyright (C) 2015 Alexandre Detiste <alexandre@detiste.be>
# License: MIT

# create a fake Steam installation to avoid
# that steamcmd uses "/home/\$user/Steam" instead
if [ ! -e ~/.steam ]
then
    mkdir -p ~/.steam/{appcache,config,logs,SteamApps/common}
    ln -s ~/.steam ~/.steam/root
    ln -s ~/.steam ~/.steam/steam
fi

if [ ! -e ~/.steam/steamcmd ]
then
    mkdir -p ~/.steam/steamcmd/linux32
    cp /opt/steamcmd/steamcmd.sh ~/.steam/steamcmd/steamcmd.sh
    cp /opt/steamcmd/linux32/steamcmd ~/.steam/steamcmd/linux32/steamcmd
fi

exec ~/.steam/steamcmd/steamcmd.sh "\$@"
EOF

chmod 755 usr/bin/steamcmd

PKGNAME=$PRODUCT

erc pack $PKGNAME.tar opt usr || fatal
return_tar $PKGNAME.tar
