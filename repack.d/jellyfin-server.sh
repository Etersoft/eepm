#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

move_to_opt /usr/lib64/jellyfin 

#wrong link; remake
remove_file /opt/jellyfin-server/jellyfin-web

ln -s /opt/jellyfin-web/jellyfin-web $BUILDROOT/$PRODUCTDIR/jellyfin-web

pack_file $PRODUCTDIR/jellyfin-web

# Set webdir to /opt/jellyfin-web
subst 's|JELLYFIN_WEB_OPT="--webdir=/usr/share/jellyfin-web"|JELLYFIN_WEB_OPT="--webdir=/opt/jellyfin-web"|' $BUILDROOT/etc/sysconfig/jellyfin

# Jellyfin tries to create files in /etc/jellyfin on the first run, but fails
# because it runs as the jellyfin user, not root
subst 's|JELLYFIN_CONFIG_DIR="/etc/jellyfin"|JELLYFIN_CONFIG_DIR="/var/lib/jellyfin"|' $BUILDROOT/etc/sysconfig/jellyfin

# This is required for ALT systems
if [ "$(epm print info -s)" = "alt" ]; then
    echo DOTNET_ROOT=/usr/lib64/dotnet >> $BUILDROOT/etc/sysconfig/jellyfin
fi

# Jellyfin can't find logging.default.json because of wrong name in the package
move_file /etc/jellyfin/logging.json /etc/jellyfin/logging.default.json

# Set ownership of /var/*/jellyfin to jellyfin user via systemd-tmpfiles
cat <<EOF | create_file /usr/lib/tmpfiles.d/jellyfin.conf
d /var/lib/jellyfin 0755 jellyfin jellyfin -
d /var/cache/jellyfin 0755 jellyfin jellyfin - 
d /var/log/jellyfin 0755 jellyfin jellyfin - 
EOF

add_requires dotnet-sdk-8.0

add_libs_requires

add_bin_exec_command jellyfin $PRODUCTDIR/jellyfin
