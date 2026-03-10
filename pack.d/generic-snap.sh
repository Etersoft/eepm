#!/bin/sh

TAR="$1"
RETURNTARNAME="$2"
VERSION="$3"

. $(dirname $0)/common.sh

if ! rhas "$TAR" "\.snap$" ; then
    fatal "No idea how to handle $TAR"
fi

alpkg=$(basename $TAR)
BASEDIR=$(basename $TAR .snap)

erc --here -C $BASEDIR unpack $TAR || fatal

# name: plex-desktop
# version: 1.69.1
# summary: Plex for Linux
# description:
yaml_load_vars $BASEDIR/meta/snap.yaml name version summary description

[ -n "$name" ] || fatal "Can't get name from snap.yaml"
[ -n "$version" ] || fatal "Can't get version from snap.yaml"

# hack version
if echo "$version" | grep -q "^v[0-9]" ; then
    version="$(echo $version | sed -e 's|^v||')"
fi


version="$(echo $version | sed 's/-/./g')"


mkdir -p opt/
mv $BASEDIR opt/$name

PKGNAME=$name-$version.tar

cat <<EOF >$PKGNAME.eepm.yaml
name: $name
version: $version
summary: $summary
description: $description
upstream_file: $alpkg
generic_repack: snap
EOF

test -d opt/$name || fatal "Can't find opt/$name"

# Install all icons
for f in opt/$name/meta/gui/icon.png opt/$name/meta/gui/*.svg opt/$name/meta/gui/*.png ; do
    [ -f "$f" ] || continue
    bn="$(basename "$f")"
    case "$bn" in
        *.svg) install_file "$f" "usr/share/icons/hicolor/scalable/apps/$bn" ;;
        *)     install_file "$f" "usr/share/pixmaps/$bn" ;;
    esac
done

# Install all desktop files
# Prefer usr/share/applications/ (has actual binary names in Exec=)
# Fall back to meta/gui/ (has snap wrapper names like appname.command)
desktop_src="opt/$name/meta/gui"
if ls opt/$name/usr/share/applications/*.desktop >/dev/null 2>&1 ; then
    desktop_src="opt/$name/usr/share/applications"
fi
for f in $desktop_src/*.desktop ; do
    [ -f "$f" ] || continue
    bn="$(basename "$f")"
    install_file "$f" "usr/share/applications/$bn"
    subst "s|^Icon=.*[$/].*/\([^/]*\)\$|Icon=\1|" "usr/share/applications/$bn"
    subst "s|^Comment=$|Comment=$summary|" "usr/share/applications/$bn"
done

if [ -d usr/share ] ; then
    erc pack $PKGNAME opt/$name usr/share
else
    erc pack $PKGNAME opt/$name
fi

return_tar $PKGNAME
