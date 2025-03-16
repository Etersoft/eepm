#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

PRODUCT=vkteams

. $(dirname $0)/common.sh

cat <<EOF | create_exec_file /usr/bin/$PRODUCT
#!/bin/sh
# Hack against https://bugzilla.altlinux.org/43779
# add fake desktop-file-install to path to skip desktop creating
export PATH=$PRODUCTDIR:$PATH
exec $PRODUCTDIR/$PRODUCT "\$@"
EOF

cat <<'EOF' | create_exec_file $PRODUCTDIR/desktop-file-install
#!/bin/sh
while [ -n "$1" ] ; do
    case "$1" in
        --*)
            shift
            continue
            ;;
    esac
    rm -fv "$1"
    shift
done
EOF

cat <<EOF | create_file /usr/share/applications/$PRODUCT.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=VK Teams
Comment=Official desktop application for the VK Teams messaging service
Icon=$PRODUCT
Exec=$PRODUCT -urlcommand %u
Categories=InstantMessaging;Social;Chat;Network;
Terminal=false
MimeType=x-scheme-handler/vkteams;x-scheme-handler/myteam-messenger;
Keywords=vkteams;
EOF

subst "s|.*$PRODUCTDIR/unittests.*||" $SPEC

# to skip obsoleted require libjasper.so.1()(64bit)
remove_file $PRODUCTDIR/plugins/imageformats/libqjp2.so

# to skip obsoleted libsqlite.so.0()(64bit)
remove_file $PRODUCTDIR/plugins/sqldrivers/libqsqlite2.so

add_libs_requires
