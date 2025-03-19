#!/bin/sh -x

# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT="$3"
PKG="$4"

. $(dirname $0)/common.sh


# drop forbidded paths
# https://bugzilla.altlinux.org/show_bug.cgi?id=38842
for i in / /etc /etc/init.d /etc/systemd /bin /opt /usr /usr/bin /usr/lib /usr/lib64 /usr/share /usr/share/doc /var /var/log /var/run \
        /etc/cron.daily /usr/share/icons/usr/share/pixmaps /usr/share/man /usr/share/man/man1 /usr/share/appdata /usr/share/applications /usr/share/menu \
        /usr/share/mime /usr/share/mime/packages /usr/share/icons \
        /usr/share/icons/gnome \
        /usr/share/icons/hicolor ; do
    sed \
        -e "s|/\./|/|" \
        -e "s|^%dir[[:space:]]\"$i/*\"$||" \
        -e "s|^%dir[[:space:]]$i/*$||" \
        -e "s|^\"$i/*\"$||" \
        -e "s|^$i/*$||" \
        < $SPEC > $SPEC.new
    diff -u $SPEC $SPEC.new || warning "There was some introduced system paths in the spec file"
done

for DESKTOPFILE in $BUILDROOT/usr/share/applications/*.desktop ; do
    [ -f "$DESKTOPFILE" ] || continue
    EXEC="$(get_desktop_value "$DESKTOPFILE" "Exec")"
    if echo "$EXEC" | grep -q "/" ; then
        warning "Exec path in desktop file $DESKTOPFILE contains slashes: $EXEC"
    elif [ ! -f "./usr/bin/$EXEC" ] ; then
        warning "Exec from desktop file $DESKTOPFILE missed in /usr/bin: $EXEC"
    elif [ ! -x "./usr/bin/$EXEC" ] ; then
        warning "Exec from desktop file $DESKTOPFILE exists in /usr/bin, but not executable: $EXEC"
    elif [ -z "$EXEC" ] ; then
        warning "Exec from desktop file $DESKTOPFILE is missed"
    fi
done
