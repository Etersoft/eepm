#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

APPNAME=nomachine
PKGNAME=nomachine
PRODUCTDIR=opt/$APPNAME

[ "$VERSION" = "*" ] && VERSION=""
[ -n "$VERSION" ] && ! is_url "$VERSION" || VERSION=""
[ -n "$VERSION" ] || VERSION="$(basename "$TAR" | sed -n 's|^nomachine-personal-edition_\([0-9.]*\)_.*|\1|p')"
[ -n "$VERSION" ] || fatal "Can't get package version from $TAR"

epm assure patool || fatal
case "$TAR" in
    *.rpm)
        epm assure cpio || fatal
        ;;
    *.deb)
        epm assure dpkg || fatal
        ;;
esac

erc --here unpack "$TAR" || fatal

payloads=''
for d in . */ ; do
    [ -d "$d/etc/NX/server/packages" ] || continue
    payloads="$d/etc/NX/server/packages"
    break
done
if [ -z "$payloads" ] ; then
    for d in . */ ; do
        [ -d "$d/usr/share/NX/packages/server" ] || continue
        payloads="$d/usr/share/NX/packages/server"
        break
    done
fi

mkdir -p "$PRODUCTDIR" || fatal
if [ -n "$payloads" ] ; then
    for i in "$payloads"/*.tar.gz ; do
        [ -s "$i" ] || continue
        erc --here unpack "$i" || fatal
    done
    [ -d NX ] || fatal "Can't find unpacked NoMachine payload"
    cp -a NX/. "$PRODUCTDIR/" || fatal
elif [ -d usr/NX ] ; then
    cp -a usr/NX/. "$PRODUCTDIR/" || fatal
elif [ -d opt/NX ] ; then
    cp -a opt/NX/. "$PRODUCTDIR/" || fatal
else
    fatal "Can't find NoMachine payload packages"
fi

[ -x "$PRODUCTDIR/bin/nxplayer" ] || fatal "Can't find nxplayer"

mkdir -p usr/share/applications usr/share/pixmaps || fatal
cp "$PRODUCTDIR/share/images/player/server-logo.png" usr/share/pixmaps/$APPNAME.png || fatal

cat <<EOF >usr/share/applications/$APPNAME.desktop
[Desktop Entry]
Name=NoMachine
Comment=NoMachine remote desktop client
Exec=$APPNAME
Icon=$APPNAME
Terminal=false
Type=Application
Categories=Network;RemoteAccess;
EOF

rm -rf etc/NX etc/pam.d
mkdir -p etc/NX/server/localhost usr/lib/systemd/system usr/lib/sysusers.d usr/lib/tmpfiles.d || fatal
cp "$PRODUCTDIR/scripts/etc/nxserver" etc/NX/nxserver || fatal
cp "$PRODUCTDIR/scripts/etc/nxnode" etc/NX/nxnode || fatal
chmod 755 etc/NX/nxserver etc/NX/nxnode || fatal

for cfg in node player runner server ; do
    sed "s|/usr/NX|/$PRODUCTDIR|g" "$PRODUCTDIR/scripts/etc/localhost/$cfg.cfg" > "etc/NX/server/localhost/$cfg.cfg" || fatal
done

case "$(epm print info -s)" in
    debian|ubuntu)
        nxdist=debian
        ;;
    fedora)
        nxdist=fedora
        ;;
    *)
        nxdist=redhat
        ;;
esac

for cfg in node server ; do
    sed "s|/usr/NX|/$PRODUCTDIR|g" "$PRODUCTDIR/etc/$cfg-$nxdist.cfg.sample" > "$PRODUCTDIR/etc/$cfg.cfg" || fatal
done

cp "$PRODUCTDIR/scripts/systemd/nxserver.service" usr/lib/systemd/system/nxserver.service || fatal

cat <<EOF >usr/lib/sysusers.d/$APPNAME.conf
u nx - "NoMachine service user" /var/NX/nx
u nxhtd - "NoMachine web service user" /var/NX/nxhtd
EOF

cat <<EOF >usr/lib/tmpfiles.d/$APPNAME.conf
d /var/NX 0755 root root -
d /var/NX/nx 0750 nx nx -
d /var/NX/nx/.nx 0750 nx nx -
d /var/NX/nxhtd 0750 nxhtd nxhtd -
d /var/log/NX 0755 nx nx -
d /$PRODUCTDIR/var/log 0750 nx root -
d /$PRODUCTDIR/var/run 0750 nx root -
f /$PRODUCTDIR/etc/sshstatus 0644 nx root -
EOF

if [ -d "$PRODUCTDIR/scripts/etc/pam.d" ] ; then
    mkdir -p etc/pam.d || fatal
    cp -a "$PRODUCTDIR/scripts/etc/pam.d/." etc/pam.d/ || fatal
fi

pack_files="$PRODUCTDIR etc/NX usr/share/applications usr/share/pixmaps usr/lib/systemd/system usr/lib/sysusers.d usr/lib/tmpfiles.d"
[ ! -d etc/pam.d ] || pack_files="$pack_files etc/pam.d"
erc pack "$PKGNAME-$VERSION.tar" $pack_files || fatal

cat <<EOF >"$PKGNAME-$VERSION.tar.eepm.yaml"
name: $PKGNAME
version: $VERSION
group: Networking
license: Proprietary
url: https://www.nomachine.com
summary: NoMachine remote desktop client and server
description: NoMachine remote desktop client and server repacked from the official upstream package.
EOF

return_tar "$PKGNAME-$VERSION.tar"
